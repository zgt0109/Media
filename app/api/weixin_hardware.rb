# coding: utf-8

require 'uri'

class WeixinHardware

  class << self
    def respond_hanming_wifi(wx_user, mp_user, message)
      Weixin.respond_text(wx_user.uid, mp_user.uid, 'hanming wifi')
    end
    
    # resultCode
    # string
    # true
    # 请求结果
    # 1-成功
    # 0-失败
    # 2-非法访问(ip 受限) 3-数据结构无效
    # 9-系统异常
    # 10-数据格式无效 12-微网站账号无效 13-微网站密码无效 17-微信公众账号唯一标识无效
    def respond_wifi(wx_user, mp_user, message)
      if wx_user.match_at && wx_user.match_at <= 5.minutes.ago # 大于5分钟直接退出
        respond_exit(wx_user, mp_user, '您离开微信wifi状态超过5分钟，现自动退出wifi状态')
      end

      hash          = { mobileNo: '18060086001', guid: mp_user.uid, openid: wx_user.uid, wifiVerifyCode: message }
      rest_params   = WifiLib::WifiBridge.encoding_message hash.to_json
      ret      = RestClient.post(
          'http://api.chaowifi.com/login/get_wifi_verify.do',
          { msgId: '5', platId: '1203', param: rest_params }
      )
      json_ret = JSON.parse(ret)
      Rails.logger.info "the json ret is #{json_ret}"
      rc_en       = json_ret['result']
      de_string   = WifiLib::WifiBridge.decoding_message rc_en.to_s
      result_code = JSON.parse(de_string)['resultCode'].to_i

      content = if result_code == 1
        wx_user.normal! #回到正常状态
        '连接wifi成功!'
      else
        '验证码不正确'
      end
      Weixin.respond_text(wx_user.uid, mp_user.uid, content)
    end

    #印立得
    def respond_inlead_print(wx_user, mp_user, activity, raw_post)
      return respond_exit(wx_user, mp_user) if wx_user.match_at <= 5.minutes.ago # 大于5分钟直接退出

      print_url      = mp_user.supplier.supplier_prints.small.first.url
      from_user_name = wx_user.uid
      to_user_name   = mp_user.uid
      if activity && activity.supplier_print?
        result  = RestClient.post(print_url, raw_post, content_type: :xml, accept: :xml)
        if result.start_with?('<xml>')
          wx_user.print! #切换为打印模式
          Weixin.respond_text(from_user_name, to_user_name, activity.summary)
        else
          Weixin.respond_text(from_user_name, to_user_name, '打印图片失败，请重新上传图片')
        end
      elsif activity && activity.exit_supplier_print? #退出微打印状态
        respond_exit(wx_user, mp_user, activity.summary)
      else #直接转发给inleader
        result = RestClient.post(print_url, raw_post, content_type: :xml, accept: :xml)
        wx_user.print! #切换为打印模式
        result
      end
    end

    # welomo
    def respond_welomo_print(wx_user, mp_user, activity, raw_post, options={})
      # WinwemediaLog::Base.logger('wxprint', "welomo print raw_post: #{raw_post}, params: #{options}")
      return if mp_user.supplier.supplier_prints.welomo.normal.count == 0

      from_user_name, to_user_name = wx_user.uid, mp_user.uid

      if activity 
        #进入或退出微打印模式
        if activity.enter_welomo_print?
          wx_user.welomo_print!
          Weixin.respond_text(from_user_name, to_user_name, activity.summary || '请上传一张图片试试看')
        elsif activity.exit_welomo_print?
          respond_exit(wx_user, mp_user, activity.summary || '您已退出打印图片模式')
        elsif wx_user.try(:welomo_print?)
          post_to_welomo(wx_user, mp_user, raw_post, options)
        end
      elsif wx_user.try(:welomo_print?)
        post_to_welomo(wx_user, mp_user, raw_post, options)
      end
    end

    def post_to_welomo(wx_user, mp_user, raw_post, options={})
      from_user_name, to_user_name = wx_user.uid, mp_user.uid

      if wx_user.try(:welomo_print?)
        if wx_user.match_at <= 5.minutes.ago
          # 大于5分钟直接退出
          respond_exit(wx_user, mp_user)
        else
          #直接转发给 welomo
          begin
            supplier_print = mp_user.supplier.supplier_prints.welomo.normal.first
            signature = Digest::SHA1.hexdigest([supplier_print.token, options[:timestamp], options[:nonce]].map!(&:to_s).sort.join)

            post_uri = URI(supplier_print.url)
            post_uri.query = Rack::Utils.parse_query(post_uri.query).merge(signature: signature, timestamp: options[:timestamp], nonce: options[:nonce]).to_param
            result = RestClient.post(post_uri.to_s, raw_post, content_type: :xml, accept: :xml)

            WinwemediaLog::Base.logger('wxprint', "welomo print result: #{result}")

            if result.start_with?('<xml>')
              result
            else
              Weixin.respond_text(from_user_name, to_user_name, '请上传一张图片试试看，如有问题请联系商家。')
            end
          rescue => error
            WinwemediaLog::Base.logger('wxprint', "welomo print error: #{error.message} => #{error.backtrace}")

            Weixin.respond_text(from_user_name, to_user_name, '打印图片失败，请重新上传图片')
          end
        end
      end
    end

    def respond_exit(wx_user, mp_user, message = '您开启打印图片模式超过5分钟未做任何操作，已自动退出打印图片模式。')
      wx_user.normal!

      Weixin.respond_text(wx_user.uid, mp_user.uid, message)
    end    
  end

end
