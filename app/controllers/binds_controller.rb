class BindsController < ApplicationController
  layout 'binds'

  before_filter :load_wx_mp_user, except: [:index, :set_process, :bind_process]

  ADVANCED_BASE_URL = "mp.weixin.qq.com/advanced/advanced"

  HOST = "https://mp.weixin.qq.com"
  LOGIN_URL = "https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN"
  VERIFY_IMG_URL = "https://mp.weixin.qq.com/cgi-bin/verifycode?"
  INDEX_URL = "https://mp.weixin.qq.com/cgi-bin/home?t=home/index&lang=zh_CN&token="
  ADVANCED_URL = "https://#{ADVANCED_BASE_URL}?action=index&t=advanced/index&lang=zh_CN&token="
  ADVANCED_DEV_URL = "https://#{ADVANCED_BASE_URL}?action=dev&t=advanced/dev&lang=zh_CN&token="
  ADVANCED_DEV_JSON_URL = "https://#{ADVANCED_BASE_URL}?action=dev&t=advanced/dev&lang=zh_CN&f=json&token="
  DEV_INTERFACE_URL = "https://#{ADVANCED_BASE_URL}?action=interface&t=advanced/interface&lang=zh_CN&token="
  CALLBACK_PROFILE_URL = "https://mp.weixin.qq.com/advanced/callbackprofile?t=ajax-response&lang=zh_CN&token="
  SKEYFORM_URL = "https://mp.weixin.qq.com/misc/skeyform?form=advancedswitchform&lang=zh_CN"

  REFERER_H = "Referer"
  COOKIE_H = "Cookie"
  CONTENT_TYPE_H = "Content-Type"
  USER_AGENT_H = "User-Agent"
  CONTENT_TYPE = "application/x-www-form-urlencoded; charset=UTF-8"
  USER_AGENT = "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.172 Safari/537.22"
  UTF_8 = "UTF-8"

  def index
    # if current_user.wx_mp_user
    #   return redirect_to console_path, alert: '您已经绑定过公众号'
    # end

    @wx_mp_user = WxMpUser.new(supplier_id: current_user.id)
    if request.get?
      # session[:show_verify_img] = nil
      if session[:show_verify_img]
        session[:wx_cookies] = session[:wx_cookies] || ["pgv_pvid=#{rand(100000000...1000000000)}"].join('; ')
        @verify_img = get_verify_img({r: (Time.now.to_f*1000).round, username: CGI::escape(session[:username])})
      else
        session[:wx_cookies] = ["pgv_pvid=#{rand(100000000...1000000000)}"].join('; ')
        session[:wx_token] = nil
      end
    else
      if params[:username].blank? or params[:password].blank?
        flash[:alert] = '用户名或密码为空'
        return redirect_to :back
      end

      # logger.info "=====index post session wx token:#{session[:wx_token]}"
      # return redirect_to binding_binds_url if session[:wx_token] #test for not sign in every times

      res = login_wx(params)
      WinwemediaLog::Bind.add("bind login response body:#{res.body}")

      @response_body = res.body
      jbody = JSON.parse(res.body)
      if (jbody['base_resp']['ret'] == 0 and jbody['base_resp']['err_msg'] == "ok")
        session[:wx_token] = /token=(.*?)$/.match(jbody['redirect_url']).captures[0]
        WinwemediaLog::Bind.add("login success!! session[:wx_token]:#{session[:wx_token]}; #{/token=(.*?)$/.match(jbody['redirect_url'])}")
        cookies = []
        res.response['set-cookie'].split(', ').each{|c1| cookies.push(c1.split('; ')[0])}
        new_cookies_hash = cookie_to_hash(cookies.join('; '))
        old_cookies_hash = cookie_to_hash(session[:wx_cookies])
        old_cookies_hash.delete('sig') if old_cookies_hash['sig']

        session[:wx_cookies] = hash_to_cookie(old_cookies_hash.merge(new_cookies_hash))
        WinwemediaLog::Bind.add("session[:wx_cookies]: #{session[:wx_cookies]}")
        open_id = session[:wx_cookies].to_s.split("slave_user=").last.split(";").first
        @wx_mp_user.update_uid_to(open_id) if open_id =~ /gh_/

        name = get_nick_name
        mp_users = WxMpUser.where("name = ? or username = ? ", name, params[:username])
        if mp_users.count == 0 #the wx mp account is not used
          if @wx_mp_user.name.nil? # new wx_mp_user
            @wx_mp_user.name = name
            @wx_mp_user.username = params[:username]
            @wx_mp_user.password = params[:password]
            if @wx_mp_user.save
              respond_to {|format| format.html { redirect_to binding_binds_url}}
            else
              @response_body = "{\"ErrCode\": -9901}"
            end
          else # update wx_mp_user
            if @wx_mp_user and  @wx_mp_user.update_attributes(name: (name.blank? ? @wx_mp_user.name : name), username: params[:username], password: params[:password])
              respond_to {|format| format.html { redirect_to binding_binds_url}}
            else
              @response_body = "{\"ErrCode\": -9902}"
            end
          end
        else
            mp_user = mp_users.first
            if @wx_mp_user and  @wx_mp_user.update_attributes(name: (name.blank? ? @wx_mp_user.name : name), username: params[:username], password: params[:password])
              mp_user.update_attributes(status: WxMpUser::DISABLED, binds_count: 0) if @wx_mp_user && @wx_mp_user.id != mp_user.try(:id)
              respond_to {|format| format.html { redirect_to binding_binds_url}}
            else
              @response_body = "{\"ErrCode\": -9903}"
            end
        end
      else
        # session[:show_verify_img] = true if session[:show_verify_img].nil? && Rails.env.production?
        session[:username] = params[:username]
        # @verify_img = get_verify_img({r: (Time.now.to_f*1000).round, username: CGI::escape(session[:username])})# if session[:show_verify_img]
        #@response_body = "{\"ErrCode\": #{jbody['base_resp']['ret']}}"
        respond_to {|format| format.html { render 'index' }}
      end
    end
  rescue => e
    WinwemediaLog::Bind.add("bind login error :#{e}")
    if (res.body =~ /Bad\s+Gateway/).nil?
      @response_body = "{\"ErrCode\": -9905}"
    else
      @response_body = "{\"ErrCode\": -9904}"
    end
  end

  def rebind
    # return redirect_to account_url, notice: "您还没有绑定公众账号!" unless @wx_mp_user
    # return redirect_to account_url, notice: "您已经绑定过两次公众账号，无法重新绑定!" if @wx_mp_user.binds_count > 1

    if request.get?
      # session[:show_verify_img] = nil
      if session[:show_verify_img]
        session[:wx_cookies] = session[:wx_cookies] || ["pgv_pvid=#{rand(100000000...1000000000)}"].join('; ')
        @verify_img = get_verify_img({r: (Time.now.to_f*1000).round, username: CGI::escape(session[:username])})
      else
        session[:wx_cookies] = ["pgv_pvid=#{rand(100000000...1000000000)}"].join('; ')
        session[:wx_token] = nil
      end
    else
      # logger.info "=====index post session wx token:#{session[:wx_token]}"
      # return redirect_to binding_binds_url if session[:wx_token] #test for not sign in every times

      res = login_wx(params)
      WinwemediaLog::Bind.add("rebind login response body:#{res.body}")

      @response_body = res.body
      jbody = JSON.parse(res.body)
      if (jbody['base_resp']['ret'] == 0 and jbody['base_resp']['err_msg'] == "ok")
        session[:wx_token] = /token=(.*?)$/.match(jbody['redirect_url']).captures[0]
        WinwemediaLog::Bind.add("relogin success!! session[:wx_token]:#{session[:wx_token]}; #{/token=(.*?)$/.match(jbody['redirect_url'])}")

        cookies = []
        res.response['set-cookie'].split(', ').each{|c1| cookies.push(c1.split('; ')[0])}
        new_cookies_hash = cookie_to_hash(cookies.join('; '))
        old_cookies_hash = cookie_to_hash(session[:wx_cookies])
        old_cookies_hash.delete('sig') if old_cookies_hash['sig']

        session[:wx_cookies] = hash_to_cookie(old_cookies_hash.merge(new_cookies_hash))
        WinwemediaLog::Bind.add("session[:wx_cookies]: #{session[:wx_cookies]}")

        name = get_nick_name
        mp_users = WxMpUser.where("name = ? or username = ? ", name, params[:username])
        if mp_users.count == 0 #the wx mp account is not used
          if @wx_mp_user and  @wx_mp_user.update_attributes(name: (name.blank? ? @wx_mp_user.try(:name) : name), username: params[:username], password: params[:password], status: WxMpUser::PENDING, token: SecureRandom.hex(10))
            respond_to {|format| format.html { redirect_to binding_binds_url(type: 'rebind') } }
          else
            @response_body = "{\"ErrCode\": -9902}"
          end
        else
          mp_user = mp_users.first
          if @wx_mp_user and  @wx_mp_user.update_attributes(name: (name.blank? ? @wx_mp_user.try(:name) : name), username: params[:username], password: params[:password], status: WxMpUser::PENDING, token: SecureRandom.hex(10))
            mp_user.update_attributes(status: WxMpUser::DISABLED, binds_count: 0) if @wx_mp_user && @wx_mp_user.id != mp_user.try(:id)
            respond_to {|format| format.html { redirect_to binding_binds_url(type: 'rebind') } }
          else
            @response_body = "{\"ErrCode\": -9903}"
          end
        end
      else
        # session[:show_verify_img] = true if session[:show_verify_img].nil? && Rails.env.production?
        session[:username] = params[:username]
        # @verify_img = get_verify_img({r: (Time.now.to_f*1000).round, username: CGI::escape(session[:username])})# if session[:show_verify_img]
        respond_to do |format| 
          format.html { 
            flash[:alert] = '账号或密码不正确'
            render 'rebind'
          }
        end
      end
    end
  rescue => e
    WinwemediaLog::Bind.add("bind login error :#{e}")
    if (res.body =~ /Bad\s+Gateway/).nil?
      @response_body = "{\"ErrCode\": -9905}"
    else
      @response_body = "{\"ErrCode\": -9904}"
    end
  end

  def binding
    session[:process_status] = nil
  end

  def bind_validate
  end

  def step1
    if request.post? 
      if @wx_mp_user.update_attributes(params[:wx_mp_user].merge(status: WxMpUser::PENDING, token: SecureRandom.hex(10), key: WxMpUser.generate_key))
        redirect_to step2_binds_path
      else
        redirect_to step1_binds_path, alert: "绑定失败:#{@wx_mp_user.errors.full_messages}"
      end
    end
  end

  def step2
  end

  def binded
  end

  def set_process(process_id)
    tmp = process_id * 25
    @process_status[:try_times] = 0
    @process_status[:process] = process_id
    @process_status[:percent] = rand((tmp - 10)..tmp)
  end

  def bind_process
    @process_status = session[:process_status]
    if @process_status.is_a?(Hash)
      case @process_status[:process]
      when 0
        # 第零步 验证微信帐号和密码是否正确
        wx_mp_user = current_user.wx_mp_user
        if wx_mp_user.username.present? and wx_mp_user.password.present? and wx_mp_user.url.present? and wx_mp_user.token.present?
          self.set_process(1)
        else
          @process_status[:st] = -10 #验证公众号失败
        end
      when 1
        # 第一部 关闭编辑模式
        ce_res = skeyform({flag: 0, type: 1, token: session[:wx_token]})
        WinwemediaLog::Bind.add("process 1 close edit respose: #{ce_res.body}")
        json_res = JSON.parse(ce_res.body)
        if json_res["base_resp"] && json_res["base_resp"]["ret"] < 0
          if @process_status[:try_times] == 2
            # 如果已经重试2次了，放弃重试，跳到下一步
            self.set_process(2)
            WinwemediaLog::Bind.add("关闭编辑模式失败：#{ce_res.body} headers_and_args: #{@headers_and_args}")
            @process_status[:error_msg] ||= "关闭编辑模式失败，"
            @process_status[:error_code] ||= ce_res.body.inspect
          else
            @process_status[:try_times] += 1
          end
        else
          # WinwemediaLog::Bind.add("关闭编辑模式成功：#{ce_res.body} headers_and_args: #{@headers_and_args}")
          self.set_process(2)
        end
      when 2
        # 第二步 打开开发模式
        od_res = skeyform({flag: 1, type: 2, token: session[:wx_token]})
        WinwemediaLog::Bind.add("process 2 open dev respose: #{od_res.body}")
        json_res = JSON.parse(od_res.body)
        if json_res["base_resp"] && json_res["base_resp"]["ret"] < 0
          if @process_status[:try_times] == 2
            # 如果已经重试2次了，放弃重试，跳到下一步
            self.set_process(3)
            WinwemediaLog::Bind.add("打开开发模式失败：#{od_res.body} headers_and_args: #{@headers_and_args}")
            @process_status[:error_msg] ||= "开启开发模式失败，"
            @process_status[:error_code] ||= od_res.body.inspect
          else
            @process_status[:try_times] += 1
          end
        else
          # WinwemediaLog::Bind.add("打开开发模式成功：#{od_res.body} headers_and_args: #{@headers_and_args}")
          self.set_process(3)
        end
      when 3
        # 第三部 设置 url 和 token
        wx_mp_user = current_user.wx_mp_user
        sut_res = submit_url_token({url: wx_mp_user.try(:url), token: wx_mp_user.try(:token), key: wx_mp_user.try(:key)})
        WinwemediaLog::Bind.add("process 3 set url and token respose: #{sut_res.body}")
        jbody = JSON.parse(sut_res.body) rescue {'ret' => -1}
        if jbody['ret'].to_i == 0
          self.set_process(4)
        elsif jbody['ret'].to_i == -204
            @process_status[:error_msg] = "绑定失败，请确认已在公众平台设置以下信息：\n公众帐号头像、描述和运营地区。\n"
            @process_status[:error_code] = sut_res.body.inspect
            @process_status[:st] = -13 #提交绑定接口失败
        else
          if @process_status[:try_times] == 2
            # 如果已经重试2次了，放弃重试，抛出失败消息
            @process_status[:st] = -13 #提交绑定接口失败
            if jbody['ret'].to_i == -301
              @process_status[:error_msg] = "绑定失败，检查 Token 请求超时，"
              @process_status[:error_code] = sut_res.body.inspect
            else
              # 其他类型的错误
              @process_status[:error_msg] ||= "绑定过程中出现问题，可能是在公众平台开启了修改服务器配置的保护（安全中心 > 安全保护 > 修改服务器配置），请关闭重试或人工绑定，"
              @process_status[:error_code] ||= sut_res.body.inspect
              VitalLog.add_log("auto_bind", current_user.try(:id), @process_status[:error_msg], @process_status[:error_code])
            end
            WinwemediaLog::Bind.add("提交绑定接口失败, url:#{wx_mp_user.try(:url)}; token:#{wx_mp_user.try(:token)}; @process_status: #{@process_status}")
          else
            @process_status[:try_times] += 1
          end
        end
      when 4
        # 第四步 绑定完成
        # wx_mp_user = current_user.wx_mp_user
        # wx_mp_user.status = WxMpUser::ACTIVE
        @process_status[:percent] = 100
        @process_status[:st] = 1 #绑定完成
      else
        @process_status[:error_msg] ||= "出现意外的操作流程，绑定失败，请重试或人工绑定，"
        @process_status[:st] = -13
      end
      session[:process_status] = @process_status
      respond_to{ |format| format.json { render json: @process_status} }
    else
      @process_status = {st: 0, process: 0, percent: rand(1..10), try_times: 0, error_msg: nil, error_code: nil}
      session[:process_status] = @process_status
      respond_to{ |format| format.json { render json: @process_status} }
    end
  rescue => error
    WinwemediaLog::Bind.add(error)
    @process_status[:st] = -1 #运行中异常
    WinwemediaLog::Bind.add("bind_process error, @process_status: #{@process_status}")
    @process_status[:error_msg] ||= "绑定接口异常终止，"
    @process_status[:error_code] ||= error.inspect
    session[:process_status] = @process_status
    respond_to { |format| format.json { render json: @process_status} }
  end

  private

  def load_wx_mp_user
    @wx_mp_user = current_user.wx_mp_user || current_user.create_wx_mp_user!(name: current_user.nickname)
  end

  def md5(pwd)
    Digest::MD5::hexdigest(pwd[0..15])
  end

  def hash_to_uri_args(params = {})
    params.map{|k,v| "#{k}=#{v}"}.join("&")
  end

  def cookie_to_hash(cookies = '')
    cookies = cookies.split('; ')
    cookies_hash = {}
    cookies.each{|cookie|

      c_s = cookie.split('=')
      k = c_s[0]
      if c_s.size > 2
        c_s.delete_at(0)
        v = c_s.join('=')
      else
        v = c_s[1]
      end
      v = v||''
      while "=" === cookie.at(cookie.length-1) do
        v = v+"="
        cookie = cookie[0...(cookie.length-1)]
      end

      cookies_hash[k] = v
    }
    cookies_hash
  end

  def hash_to_cookie(cookies_hash = {})
    cookies_hash.map{|k,v| "#{k}=#{v}"}.join("; ")
  end

  def https_get(url, headers={})
    logger.info "https get : #{url}=======#{headers}"
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if (uri.scheme == "https")
    request = Net::HTTP::Get.new(uri.request_uri)
    headers.map { |k, v|  request[k] = v}

    response = http.request(request)
    response
  end

  #data => String like username=jarry&password=1111
  def https_post(url, data, headers={})
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https'), verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request_post(uri.request_uri, data, headers)
    end
  end

  #p => Hash like {'username' => 'jarry', 'password' => '1111'}
  def https_post_full(url, p, headers={})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER if (uri.scheme == "https")
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(p)
    headers.map { |k, v|  request[k] = v}
    response = http.request(request)
  end

  def login_wx(params = {})
    headers = {
      COOKIE_H => session[:wx_cookies],
      REFERER_H => HOST,
      CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT
    }

    p = {
      "f" => "json",
      "imgcode" => params[:imgcode] || '',
      "pwd" => md5(params[:password].to_s),
      "username" => params[:username],
    }

    https_post(LOGIN_URL, hash_to_uri_args(p), headers)
  end


  # callback_encrypt_mode 0：明文模式，1：兼容模式，2：安全模式
  # callback_token  b63c3139d378d342d0d07c717679c201
  # encoding_aeskey Fsn8O2pHmMo8y0LMZlAGEa0yIMvZsHyDSK6A8cF4hQg
  # operation_seq 201017526
  # url http://5438d562e5f06.vip2.v-ct.com/mpapi
  def submit_url_token(params = {})
    headers = {
      REFERER_H => "#{DEV_INTERFACE_URL}#{session[:wx_token]}",
      COOKIE_H => session[:wx_cookies] || '',
      CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT
    }

    p = {
      "url" => params[:url], #'http://test.winwemedia.com/api/service?id=MTAwMDE='
      "callback_token" => params[:token], #'bd1328303830c909eda0'
      "encoding_aeskey" => params[:key],
      "callback_encrypt_mode" => '0'
    }
    
    https_post("#{CALLBACK_PROFILE_URL}#{session[:wx_token]}", hash_to_uri_args(p), headers)
  end

  # params{编辑模式 => flag:0关闭1打开 type:1 开发模式 => flag:0关闭1打开 type:2}
  def skeyform(params = {})
    headers = {
      REFERER_H => "#{ADVANCED_DEV_URL}#{session[:wx_token]}",
      COOKIE_H => session[:wx_cookies] || '',
      CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT
    }

    p = {
      "flag" => params[:flag],
      "type" => params[:type],
      "token" => params[:token]
    }
    @headers_and_args = {:args => p, :headers => headers}.inspect
    https_post(SKEYFORM_URL, hash_to_uri_args(p), headers)
  end

  def get_verify_img(params = {})
    headers = {
      COOKIE_H => session[:wx_cookies],
      REFERER_H => HOST,
      # CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT
    }
    verify_res = https_get("#{VERIFY_IMG_URL}#{hash_to_uri_args(params)}", headers)

    cookies = []
    set_cookie = verify_res.response['set-cookie']
    set_cookie.split(', ').each{|c1| cookies.push(c1.split('; ')[0])} if set_cookie
    res_cookies_hash = cookie_to_hash(cookies.join('; '))
    wx_cookies_hash = cookie_to_hash(session[:wx_cookies])
    wx_cookies_hash['sig'] = res_cookies_hash['sig']
    session[:wx_cookies] = hash_to_cookie(wx_cookies_hash)
    logger.info " session[:wx_cookies]: #{ session[:wx_cookies]}"

    file_name = "#{Rails.root.to_s}/public/images/verify/#{params[:r]}_#{CGI::unescape(params[:username])}.png"
    open(file_name, "wb") { |file| file.write(verify_res.body) }
    file_name = /(\/images\/.*?)$/.match(file_name).captures[0]
  end

  def get_index_page
    headers = {
      #"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Encoding" => "gzip, deflate",
      #"Accept-Language" => "zh-cn,zh;q=0.8,en-us;q=0.5,en;q=0.3",
      #"Connection" => "keep-alive",
      COOKIE_H => session[:wx_cookies] || '',
      "Host" => "mp.weixin.qq.com",
      REFERER_H => "#{HOST}/",
      #CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT,
    }
    WinwemediaLog::Bind.add("get_index_page: url = #{INDEX_URL}#{session[:wx_token]} ; headers = #{headers}")
    https_get("#{INDEX_URL}#{session[:wx_token]}", headers) if session[:wx_token]
  end

  def get_user_info
    headers = {
      COOKIE_H => session[:wx_cookies] || '',
      REFERER_H => "#{HOST}/",
      USER_AGENT_H => USER_AGENT,
    }
    open_id = headers.to_s.split("slave_user=").last.split(";").first
    #@wx_mp_user.update_attributes(uid: open_id) if open_id =~ /gh_/
    @wx_mp_user.update_uid_to(open_id) if open_id =~ /gh_/
    WinwemediaLog::Bind.add("get_user_info: url = #{ADVANCED_DEV_JSON_URL}#{session[:wx_token]} ; headers = #{headers}")
    https_get("#{ADVANCED_DEV_JSON_URL}#{session[:wx_token]}", headers) if session[:wx_token]
  end

  def get_nick_name
    user_info = get_user_info
    if user_info
      user_info = user_info.body
      WinwemediaLog::Bind.add("after get_user_info: user_info is #{user_info}")
    else
      WinwemediaLog::Bind.add("after get_user_info: user_info is nil!")
    end
    nick_name = /"nick_name":"(.*?)"/.match(user_info) if user_info
    WinwemediaLog::Bind.add("weixin nick_name: #{nick_name.captures[0]}") if user_info
    nick_name.nil? ? '' : nick_name.captures[0]
  end

  def get_advanced_page
    headers = {
      COOKIE_H => session[:wx_cookies] || '',
      REFERER_H => HOST,
      CONTENT_TYPE_H => CONTENT_TYPE,
      USER_AGENT_H => USER_AGENT
    }
    https_get("#{ADVANCED_URL}#{session[:wx_token]}", headers) if session[:wx_token]
  end

end
