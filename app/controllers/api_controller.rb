# -*- coding: utf-8 -*-
class ApiController < ApplicationController
  include WxReplyMessage
  include ApiControllerHelper

  skip_before_filter *ADMIN_FILTERS, :verify_authenticity_token
  before_filter :check_signature!, only: :service

  def default_url_options
    {host: Settings.mhostname}
  end

  def host
    "http://#{Settings.mhostname}"
  end

  def service
    @start_time = Time.now
    @is_success = @checked ? 1 : 0
    $encrypt_type  = params[:encrypt_type].to_s
    $app_id = params[:app_id].to_s

    return @echostr if so_resecse_test

    return @echostr = serve_get_wx_api if request.get?
    return log_and_respond_error('公众账号Token已过期', "no mp_user for: #{params}", plain_text: false) unless @checked

    @xml = $encrypt_type.to_s.eql?('aes') && $app_id.present? ? decrypt_xml : params[:xml]
    return log_and_respond_error('参数错误', "no xml data: #{params}") if @xml.blank?

    @from_user_name = @xml[:FromUserName]
    @to_user_name   = @xml[:ToUserName]

    @echostr = serve_post_wx_api
  rescue => error
    logger.error "request params #{params}, error: #{error.message} -> #{error.backtrace.inspect}"
    log_and_respond_error('系统繁忙', "request params #{params}, error: #{error.message} -> #{error.backtrace}")
  ensure
    attrs = @xml.is_a?(Hash) ? params.merge(xml: @xml) : params
    attrs = attrs.merge(ReplyMsg: @echostr, IsSuccess: @is_success, ConnectTime: Time.now - @start_time)
    WinwemediaLog::Base.logger('weixin_logs', attrs.to_json)
    render text: @echostr

    send_kf_text_message
  end

  private

  def so_resecse_test
    #{"ToUserName"=>"gh_3c884a361561", "FromUserName"=>"ozy4qt1eDxSxzCr0aNT0mXCWfrDE", "CreateTime"=>"1423617739", "MsgType"=>"text", "Content"=>"QUERY_AUTH_CODE:HGwmE-HCBBuWAF72DkX75DZNH4Pgqb0XqbfF5LnmnZHoeXj3wfH4nDJyM63MWg8D", "MsgId"=>"6114391631216365994"}
    #{"ToUserName"=>"gh_3c884a361561", "FromUserName"=>"ozy4qt1eDxSxzCr0aNT0mXCWfrDE", "CreateTime"=>"1423617744", "MsgType"=>"text", "Content"=>"TESTCOMPONENT_MSG_TYPE_TEXT", "MsgId"=>"6114391652691202477"} 
    #{"ToUserName"=>"gh_3c884a361561", "FromUserName"=>"ozy4qt1eDxSxzCr0aNT0mXCWfrDE", "CreateTime"=>"1423617748", "MsgType"=>"event", "Event"=>"LOCATION", "Latitude"=>"111.000000", "Longitude"=>"222.000000", "Precision"=>"333.000000"} 
    @xml = $encrypt_type.to_s.eql?('aes') && $app_id.present? ? decrypt_xml : params[:xml]
    if $app_id == 'wx570bc396a51b8ff8' && @xml[:ToUserName] == 'gh_3c884a361561'
      if @xml[:MsgType] == 'text'
        @echostr = Weixin.respond_text(@xml[:FromUserName], @xml[:ToUserName], 'TESTCOMPONENT_MSG_TYPE_TEXT_callback') if @xml[:Content] == 'TESTCOMPONENT_MSG_TYPE_TEXT'
        if @xml[:Content] =~/^QUERY_AUTH_CODE:\w+/
          @query_auth_code = @xml[:Content].split(':').last
          @echostr = Weixin.respond_text(@xml[:FromUserName], @xml[:ToUserName], '')  
        end
      elsif @xml[:MsgType] == 'event' 
        @echostr = Weixin.respond_text(@xml[:FromUserName], @xml[:ToUserName], "#{@xml[:Event]}from_callback")
      end
    end
    @echostr
  end

  def send_kf_text_message
    return unless @query_auth_code
    if $app_id == 'wx570bc396a51b8ff8' && @xml[:ToUserName] == 'gh_3c884a361561'
      url = 'https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=' + WxPluginService.component_access_token
      post_body = { component_appid: Settings.wx_plugin.component_app_id, authorization_code: @query_auth_code }.to_json

      result = HTTParty.post(url, body: post_body)
      auth_info = result['authorization_info']

      return if auth_info.blank?

      url = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=" + auth_info['authorizer_access_token']
      post_body = { touser: @xml[:FromUserName], msgtype: 'text', text: {content: "#{@query_auth_code}_from_api"} }.to_json
      HTTParty.post(url, body: post_body)
    end
  end

  def decrypt_xml
    attrs = {
      encoding_aes_key: params[:app_id].present? ? Settings.wx_plugin.encoding_aes_key : @mp_user.try(:encoding_aes_key),
      token: params[:app_id].present? ? Settings.wx_plugin.token : @mp_user.try(:token),
      encrypted_string: params[:xml][:Encrypt]
    }
    return params[:xml] if attrs[:encoding_aes_key].blank?
    aes = WeixinAes.new(attrs)
    aes.decrypt_string
    hash = aes.hash_from_encrypt
    hash[:xml]
  end

  def log_and_respond_error(error_msg, log_msg, plain_text: true)
    @is_success = 0
    WinwemediaLog::Base.logger('wxapi', log_msg)
    @echostr = plain_text ? error_msg : Weixin.respond_text(@from_user_name, @to_user_name, error_msg)
  end

  def check_signature!
    return render text: '请求参数不正确' if params[:code].blank? && params[:id].blank? && params[:app_id].blank?
    $wx_mp_user = @mp_user = WxMpUser.find_by_code_or_id_or_app_id(params[:code].to_s, Base64.decode64(params[:id].to_s), params[:app_id].to_s)
    return @checked = false unless @mp_user
    token = @mp_user.plugin? ? Settings.wx_plugin.token : @mp_user.token
    @checked = params[:signature] == Digest::SHA1.hexdigest([token, params[:timestamp], params[:nonce]].map!(&:to_s).sort.join)
  end

  def serve_get_wx_api    
    @mp_user.update_attributes(bind_type: WxMpUser::MANUAL, status: WxMpUser::ACTIVE) if @checked
    @checked ? params[:echostr] : 'Token验证失败'
  end

  def serve_post_wx_api
    @msg_type = @xml[:MsgType]
    @keyword  = @xml[:Content].try(:strip)
    @wx_user  = WxUser.follow(@mp_user, wx_user_openid: @from_user_name, wx_mp_user_openid: @to_user_name, status: WxUser::SUBSCRIBE, app_id: $app_id)
    word_or_pic_url = @msg_type == 'text' ? @keyword : @xml[:PicUrl]

    if @msg_type =~ /\Atext|image|voice\z/ && @wx_user.enter_kefu? # 人工客服接口处理
      kefu_response = WeixinKefu.request(params, @mp_user)
      return kefu_response.to_s if kefu_response != 'normal_match'
    elsif @msg_type =~ /\Atext|image\z/ && @wx_user.enter_wx_wall? # 微信墙
      message = @wx_user.wx_wall_users.last_replied.reply_wx_message(word_or_pic_url, @msg_type)
      return Weixin.respond_text(@from_user_name, @to_user_name, message) if message
    elsif @msg_type =~ /\Atext|image\z/ && @wx_user.enter_wx_shake? # 摇一摇接口处理
      wx_shake_user = @wx_user.wx_shake_users.last_replied
      message = wx_shake_user.reply_wx_message(word_or_pic_url, @msg_type)
      return Weixin.respond_text(@from_user_name, @to_user_name, message) if message
      return respond_activity(wx_shake_user.wx_shake.activity) if wx_shake_user.reply_keyword?
    end

    case @msg_type
      when 'text'     then text_request()
      when 'event'    then event_request()
      when 'location' then location_request()
      when 'image'    then image_request()
      when 'voice'    then voice_request()
      else
        WinwemediaLog::Base.logger('wxapi', "request msg_type: #{@msg_type} params: #{params}")
        respond_default_reply()
    end
  end

  def voice_request
    @wx_user.reset_match_type
    if @wx_user.greet? #如果是贺卡模式
      UserVoice.respond_voice(@wx_user, @mp_user, @xml)
    else
      @xml = @xml.dup.merge!(Content: @xml['Recognition'])
      @keyword = @xml['Recognition'].to_s.split('！').first
      text_request()
    end
  end

  def text_request
    return respond_no_auto_reply('没有输入关键词') if @keyword.blank?

    # 返回放心提加粉红包关键词回复内容
    if package = Fxt::Package.online.custom_subscribe.where(mp_openid: @to_user_name).first
      if package.subscribe_keyword == @keyword && package.subscribe_reply.present?
        return Weixin.respond_text(@from_user_name, @to_user_name, package.subscribe_reply )
      end
    end

    #return Weixin.respond_kefu(@from_user_name, @to_user_name) if @keyword == '多客服'
    return Weixin.respond_dkf(@from_user_name, @to_user_name) if @keyword == '多客服'

    print_response = SupplierPrint.respond_text(@wx_user, @mp_user, @keyword, request.raw_post)
    return print_response if print_response

    return WeixinHardware.respond_wifi(@wx_user, @mp_user, @keyword.from(2)) if @keyword =~ /\A上网.+/

    # 根据关键字获取最合适的活动
    activity = Activity.get_activity_by_keyword(@keyword, @mp_user.supplier_id)

    print_response = SupplierPrint.respond_small_print(@wx_user, @mp_user, activity)
    return print_response if print_response

    print_response = WeixinHardware.respond_welomo_print(@wx_user, @mp_user, activity, request.raw_post, params)
    return print_response if print_response

    assistant = Assistant.enabled_helper(@keyword)

    case
      when @wx_user.print?                                then WeixinHardware.respond_inlead_print(@wx_user, @mp_user, activity, request.raw_post)
      when @wx_user.wifi?                                 then WeixinHardware.respond_wifi(@wx_user, @mp_user, @keyword)
      # when @wx_user.hanming_wifi?                         then WeixinHardware.respond_hanming_wifi(@wx_user, @mp_user, @keyword)
      when @keyword == '为爱升级'                         then Weixin.respond_text(@from_user_name, @to_user_name, @mp_user.upgraded_text)
      when @keyword =~ /\A标签/ && @wx_user.share_photos? then SharePhoto.respond_share_photo(@wx_user, @mp_user, @keyword.from(2).strip)
      when @keyword =~ /\A语音/ && @wx_user.greet?        then UserVoice.respond_greet_voice(@wx_user, @mp_user, @keyword.from(2).strip)
      when assistant                                     then assistant.handle_keyword(@mp_user, @from_user_name, @keyword)
      when activity                                      then respond_activity(activity)
      when @keyword =~ /\A游戏/                           then Assistant.respond_game(@wx_user, @mp_user, @keyword)
      else                                                    respond_question()
    end
  end

  def image_request
    case
      when @wx_user.share_photos?            then SharePhoto.respond_create_share_photo(@wx_user, @mp_user, @xml[:PicUrl])
      when @wx_user.print?                   then SupplierPrint.respond_small_print_img(@wx_user, @mp_user, request.raw_post)
      when @wx_user.welomo_print?            then WeixinHardware.respond_welomo_print(@wx_user, @mp_user, nil, request.raw_post, params)
      when SupplierPrint.postcard?(@wx_user) then SupplierPrint.respond_postcard_img(@wx_user, @mp_user, request.raw_post)
      when @mp_user.supplier.industry_house? then @mp_user.house.respond_create_live_photo(@wx_user, @xml)
      else respond_default_reply()
    end
  rescue => error
    WinwemediaLog::Base.logger('wxapi', "image_request error: #{error.message} => #{error.backtrace}")
    Weixin.respond_text(@from_user_name, @to_user_name, '发送失败，请重新上传图片')
  end

  def event_request
    event          = @xml[:Event]
    ticket         = @xml[:Ticket]
    if ticket.present?
      qrcode = @mp_user.qrcodes.where(ticket: ticket).first
      if qrcode
        qrcode.create_or_normalize_log(@wx_user, @xml)
      else # 微客生活圈
        mall         = Wmall::Mall.where(supplier_id: @mp_user.supplier_id).first
        wmall_qrcode = Wmall::Qrcode.where(ticket: ticket, mall_id: mall.try(:id)).first
        if wmall_qrcode && wmall_qrcode.scene_id >= 50000
          if wmall_qrcode.qrcodeable_type == "Shop"
            return respond_wmall_activity(@from_user_name, @to_user_name, wmall_qrcode.qrcodeable)
          elsif wmall_qrcode.qrcodeable_type == "EcGood"
            return respond_wmall_ec_good(@from_user_name, @to_user_name, wmall_qrcode.qrcodeable)
          elsif wmall_qrcode.qrcodeable_type == "Coupon"
            return respond_wmall_ec_coupon(@from_user_name, @to_user_name, wmall_qrcode.qrcodeable)
          elsif wmall_qrcode.qrcodeable_type == "GroupGood"
            return respond_wmall_ec_group_good(@from_user_name, @to_user_name, wmall_qrcode.qrcodeable)
          end
        end
      end
      ''
    end
    case event
      when 'subscribe'
        # 如果mp_user是服务号并且wx_user个人信息不为空，则后台执行获取wx_user的基本信息，并将其保存到wx_users表中
        WxUserInfoUpdateWorker.fetch_and_save_user_info(@wx_user, @mp_user)

        # 微信关注红包
        FollowRedPacketWorker.send_follow_redpacket(@mp_user, @wx_user)

        wx_reply = @mp_user.first_follow_reply
        case
          when wx_reply.blank?          then Weixin.respond_text(@from_user_name, @to_user_name, '关注成功')
          when wx_reply.text?           then Weixin.respond_text(@from_user_name, @to_user_name, wx_reply.content)
          when wx_reply.activity?       then respond_activity(wx_reply.replyable)
          when wx_reply.graphic?        then respond_material_news(wx_reply.replyable)
          when wx_reply.audio_material? then Weixin.respond_music(@from_user_name, @to_user_name, wx_reply.replyable)
          when wx_reply.games?          then Weixin.respond_game(@from_user_name, @to_user_name, wx_reply.replyable)
        end
      when 'unsubscribe'
        @wx_user.unsubscribe!
        @wx_user.qrcode_logs.normal.deleted_all!
        ''
      when 'CLICK'
        wx_menu = WxMenu.where(key: @xml[:EventKey]).first
        return Weixin.respond_text(@from_user_name, @to_user_name, '菜单不存在') unless wx_menu

        if wx_menu.id == 31100 && !@mp_user.vip_users.visible.where(wx_user_id: @wx_user.id).exists?
          wx_menu = WxMenu.find_by_id(31170)
          return respond_activity(wx_menu.menuable) if wx_menu
        end

        case
          when wx_menu.text?     then Weixin.respond_text(@from_user_name, @to_user_name, wx_menu.content)
          when wx_menu.material? then respond_material_news(wx_menu.menuable)
          when wx_menu.activity? then respond_activity(wx_menu.menuable)
          when wx_menu.albums?   then Weixin.respond_album(@from_user_name, @to_user_name, wx_menu.menuable)
          when wx_menu.games?    then Assistant.respond_game(@wx_user, @mp_user, @keyword)
          when wx_menu.dkf?      then Weixin.respond_dkf(@from_user_name, @to_user_name)
          when wx_menu.try(:menuable).try(:audios?) then Weixin.respond_music(@from_user_name, @to_user_name, wx_menu.menuable)
          when wx_menu.try(:menuable).try(:videos?) then Weixin.respond_video(@from_user_name, @to_user_name, wx_menu.menuable)
        end
      when 'LOCATION'
        #上报地理位置
        @wx_user.update_attributes(location_x: @xml[:Latitude], location_y: @xml[:Longitude], location_updated_at: Time.now)
        WeixinKefu.location_request(params, @mp_user)
        ''
      when 'card_pass_check' then WeixinCard.card_pass_check(@mp_user, @xml)
      when 'user_get_card'   then WeixinCard.user_get_card(@wx_user, @mp_user, @xml)
      when 'user_del_card'   then WeixinCard.user_del_card(@mp_user, @xml)
    end
  end

  def location_request
    if @wx_user.update_attributes(location_x: @xml[:Location_X], location_y: @xml[:Location_Y], location_label: @xml[:Label], location_updated_at: Time.now)
      return @mp_user.house.respond_live_photo_location(@wx_user, @xml) if @wx_user.house_live_photos?

      shop_branches = ShopBranch.some_shop_branches(@mp_user.supplier,@wx_user)
      return Weixin.respond_text(@from_user_name, @to_user_name, '该商家暂无门店信息') if shop_branches.blank?
      around_shop_branches(shop_branches)
    end
  end

  def around_shop_branches(shop_branches)
    first_url = mobile_micro_stores_url(supplier_id: @mp_user.supplier_id, openid: @wx_user.openid, wxmuid: @mp_user.id, msg_type: "location")
    first_pic = "#{host}/location_img/#{@wx_user.id}/img.png?#{Time.now.to_f}"

    items = [ {title: "点击查看周边#{shop_branches.count}家门店", pic_url: first_pic, url: first_url} ]
    items += shop_branches.map do |branch|
      {
        title: "【#{branch.name}】#{branch.human_distance_to(@wx_user)}",
        pic_url: branch.thumbnail_url || "#{host}/assets/micro_stores/small_default.png",
        url: mobile_micro_store_url(supplier_id: @mp_user.supplier_id, id: branch.id, openid: @wx_user.openid, wxmuid: @mp_user.id)
      }
    end
    Weixin.respond_news(@from_user_name, @to_user_name, items)
  end

  def map_url
  end

  def respond_default_reply
    @is_success = 0
    text_reply = @mp_user.text_reply
    case
      when text_reply.blank?          then ''
      when text_reply.text?           then Weixin.respond_text(@from_user_name, @to_user_name, text_reply.content)
      when text_reply.activity?       then respond_activity(text_reply.replyable)
      when text_reply.graphic?        then respond_material_news(text_reply.replyable)
      when text_reply.audio_material? then Weixin.respond_music(@from_user_name, @to_user_name, text_reply.replyable)
      when text_reply.games?          then Weixin.respond_game(@from_user_name, @to_user_name, text_reply.replyable)
    end
  end

  def respond_material_news(material)
    return Weixin.respond_text(@from_user_name, @to_user_name, '素材不存在') if material.blank?
    return unless material.graphic?

    items = [weixin_news_item_for_material(material)]
    if material.multiple_graphic?
      items += material.children.map do |child|
        weixin_news_item_for_material(child, pic_size: :thumb)
      end
    end
    Weixin.respond_news(@from_user_name, @to_user_name, items)
  end

  def respond_activity(activity)
    logger.info '----------------------------------------------------------will response_activity'
    return Weixin.respond_text(@from_user_name, @to_user_name, '活动结束或不存在') unless activity

    if activity.wx_wall? && activity.setted? # 微信墙接口处理
      message = WxWallUser.reply_or_create(@wx_user, activity)
      Weixin.respond_text(@from_user_name, @to_user_name, message)
    elsif activity.shake? && activity.setted? # 摇一摇接口处理
      message = WxShakeUser.reply_or_create(@wx_user, activity)
      return Weixin.respond_text(@from_user_name, @to_user_name, message) if message
      respond_activity_directly(activity)
    elsif activity.supplier_print?
      SupplierPrint.respond_text(@wx_user, @mp_user, '微打印', request.raw_post)
    elsif activity.website?
      return Weixin.respond_text(@from_user_name, @to_user_name, '微官网暂停使用') unless activity.setted?
      # activity_notice = ActivityNotice.website_notice(activity)
      # respond_news_with_activity_notice(@from_user_name, @to_user_name, activity_notice)
      respond_activity_directly(activity)
    elsif activity.vip?
      return Weixin.respond_text(@from_user_name, @to_user_name, '会员卡暂停使用') if !activity.setted?
      activity_notice = ActivityNotice.vip_notice(activity, @from_user_name)
      respond_news_with_activity_notice(@from_user_name, @to_user_name, activity_notice, cover_pic: activity.pic_display_url)
    # elsif activity.wifi?
    #   @wx_user.wifi!
    #   return Weixin.respond_text(@from_user_name, @to_user_name, '请输入wifi验证码')
    elsif activity.old_coupon?
      result = ActivityNotice.respond_old_coupon(@wx_user, @mp_user, activity)
      result.is_a?(String) ? result : respond_news_with_activity_notice(@from_user_name, @to_user_name, *result)
    elsif activity.gua? || activity.wheel? || activity.hit_egg? || activity.slot? || activity.micro_aid?
      return Weixin.respond_text(@from_user_name, @to_user_name, '活动还未开始') unless activity.setted?
      activity_notice = ActivityNotice.ready_or_active_notice(activity)
      respond_news_with_activity_notice(@from_user_name, @to_user_name, activity_notice)
    elsif activity.fight?
      if activity.setted? || activity.apply?
        activity_notice = activity.activity_notices.active.first
        respond_news_with_activity_notice(@from_user_name, @to_user_name, activity_notice)
      else
        Weixin.respond_text(@from_user_name, @to_user_name, '活动还未开始')
      end
    elsif [1,6,7,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27,29,30,31,32,33,34,35,36,37,39,41,42,43,44,45,48,49,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81].include?(activity.activity_type_id)
      respond_activity_directly(activity)
    end
  end

  def respond_news_with_activity_notice( from_user_name, to_user_name, activity_notice, option={} )
    return Weixin.respond_text(from_user_name, to_user_name, '活动结束或不存在') unless activity_notice
    activity = activity_notice.activity
    url = case
            when activity.vip?         then pic_url = activity.pic_url; app_vips_url(anid: activity_notice.id, openid: @wx_user.openid, aid: activity_notice.activity_id, wxmuid: activity_notice.wx_mp_user_id)
            when activity.consume?     then app_consume_url(activity_id: activity_notice.activity_id, id: activity_notice.id, code: option[:code], openid: @wx_user.openid, wxmuid: activity_notice.wx_mp_user_id)
            when activity.gua?         then app_gua_url(  activity_notice.activity_id, anid: activity_notice.id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid, source: :notice)
            when activity.wheel?       then app_wheel_url(activity_notice.activity_id, anid: activity_notice.id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid, source: :notice)
            when activity.fight?       then app_fight_index_url(anid: activity_notice.id, aid: activity_notice.activity_id, openid: @wx_user.openid, wxmuid: activity_notice.wx_mp_user_id, m: 'index')
            when activity.hit_egg?     then app_hit_egg_url(activity_notice.activity, openid: @wx_user.openid, wxmuid: activity_notice.wx_mp_user_id)
            when activity.slot?        then app_slots_url(aid: activity_notice.activity_id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid)
            when activity.micro_aid?   then mobile_aids_url(activity_id: activity_notice.activity.id, supplier_id: activity.supplier_id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid)
          end

    url << '#mp.weixin.qq.com'
    pic_url ||= qiniu_image_url(activity_notice.qiniu_pic_key) || "#{host}#{option[:cover_pic]||activity_notice.try(:pic).try(:large)}"
    pic_url = "#{host}#{pic_url}" if pic_url !~ /^http/

    items = [{title: activity_notice.title, description: activity_notice.summary, pic_url: pic_url, url: url}]
    Weixin.respond_news(from_user_name, to_user_name, items)
  rescue
    Weixin.respond_text(from_user_name, to_user_name, '活动不存在')
  end

  def respond_activity_directly(activity)
    logger.info "---------------------#{activity.activity_type_id}-------------------goto response_activity_directly "
    url = case
            when activity.website?               then mobile_root_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.enroll?                then new_app_activity_enroll_url(aid: activity.id, wxmuid: activity.wx_mp_user_id, openid: @wx_user.openid)
            when activity.book_dinner?           then book_dinner_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.book_table?            then book_table_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.take_out?              then take_out_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.micro_store?           then mobile_micro_stores_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.vote?                  then mobile_vote_login_url(supplier_id: activity.supplier_id, vote_id: activity.id, openid: @wx_user.openid)
            when activity.house?                 then app_house_layouts_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.groups?                then app_activity_group_url(activity, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.surveys?               then respond_survey_activity_link(activity)
            when activity.car?                   then car_activity_url(activity)
            when activity.weddings?              then mobile_weddings_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, wid: activity.activityable_id)
            when activity.hotel?                 then "#{HOTEL_HOST}/wehotel-all/weixin/mobile/website.jsp?supplier_id=#{activity.supplier_id}&openid=#{@wx_user.openid}"
            when activity.album?                 then mobile_albums_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.educations?            then app_educations_url(cid: activity.activityable_id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.life?                  then app_lives_url(id: activity.activityable_id, aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.wshop? || activity.ec? then wshop_root_url(wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid))
            when activity.circle?                then app_business_circles_url(id: activity.activityable_id, aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.message?               then app_leaving_messages_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_bespeak?         then new_app_house_market_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_seller?          then app_house_sellers_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.booking?               then mobile_supplier_booking_url(activity)
            when activity.group?                 then mobile_groups_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.hospital?              then mobile_hospital_doctors_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.wifi?                  then "http://m.chaowifi.com/auth/wechat.do?guid=#{@to_user_name}"
            when activity.hanming_wifi?          then "#{activity.hanming_callback_url}?func=weixin&custom_wx_id=#{@from_user_name}&wx_id=#{@to_user_name}&ssid=winwemedia-#{activity.supplier_id}&resulturl=#{activity.hanming_callback_url}&resultAnchor=0"
            when activity.greet?
              @wx_user.greet! #进入语音贺卡模式
              return Weixin.respond_text(@from_user_name, @to_user_name, '您需要发送一条语音来激活你的信息哦！')
            when activity.trip?                  then mobile_trips_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.share_photo? # 图片分享模式
              @wx_user.share_photos!
              return Weixin.respond_text(@from_user_name, @to_user_name, activity.summary)
            when activity.exit_share_photo? # 退出分享模式
              @wx_user.normal!
              share = Activity.where(supplier_id: activity.supplier_id, activity_type_id: ActivityType::SHARE_PHOTO).first
              message = activity.summary.to_s.gsub!('{share_keyword}', share.try(:keyword).to_s)
              return Weixin.respond_text(@from_user_name, @to_user_name, message)
            when activity.other_photos?          then return SharePhoto.respond_other_photo(@wx_user, @mp_user, activity)
            when activity.my_photos?             then return SharePhoto.respond_my_photo(@wx_user, @mp_user, activity)
            when activity.greet?
              @wx_user.greet! #进入语音贺卡模式
              return Weixin.respond_text(@from_user_name, @to_user_name, '您需要发送一条语音来激活你的信息哦！')
            when activity.business_shop?         then mobile_business_shop_url(activity.supplier, activity.activityable, openid: @wx_user.openid)
            when activity.house_impression?      then app_house_impressions_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_live_photo?      then app_house_live_photos_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_intro?           then app_house_intros_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.ktv_order?             then app_ktv_orders_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.wbbs_community?        then mobile_wbbs_topics_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.wmall?                 then wmall_root_url(wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), supplier_id: activity.supplier_id)
            when activity.donation?              then mobile_donations_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, wid: activity.activityable_id, aid: activity.id)
            when activity.wmall_shop?            then wmall_shop_url(shop_id: activity.activityable_id, wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), supplier_id: activity.supplier_id)
            when activity.shake?
              url = "#{mobile_wx_shakes_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)}#mp.weixin.qq.com"
              pic_url = activity.pic_url(:large, host: host)
              items = [{title: activity.name, description: "#{activity.summary}\n退出请回复数字“0”", pic_url: pic_url, url: url}]
              return Weixin.respond_news(@from_user_name, @to_user_name, items)
            when activity.plot_bulletin?         then bulletins_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_repair?           then repair_complains_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid, type: 'repair')
            when activity.plot_complain?         then repair_complains_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid, type: 'complain')
            when activity.plot_telephone?        then telephones_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_owner?            then owners_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_life?             then lives_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.coupon?                then mobile_coupons_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.reservation?           then mobile_reservations_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.wave?                  then mobile_waves_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.broche?                then mobile_broche_photos_url(supplier_id: activity.supplier_id, aid: activity.id)
            when activity.oa?                    then "#{OA_HOST}/woa-all/wx/#{activity.supplier_id}/index?openid=#{@wx_user.openid}"
            when activity.fans_game?             then mobile_fans_games_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.govmail?               then mobile_govmails_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.govchat?               then mobile_govchats_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.recommend?             then recommend_mobile_location(activity.id)
            when activity.unfold?                then mobile_unfolds_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.wmall_coupon?          then wmall_coupon_url(wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), supplier_id: activity.supplier_id)
            when activity.scene?                 then mobile_scenes_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.panoramagram?          then mobile_supplier_panoramagram_url(activity)
            when activity.guess?                 then mobile_guess_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.wx_card?               then mobile_wx_cards_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id, wechat_card_js: 1)
            when activity.brokerage?             then mobile_brokerages_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.red_packet?            then mobile_red_packets_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
          end
    logger.info "------#{activity.hanming_wifi?}----#{url} ====="
    url << '#mp.weixin.qq.com' unless activity.hanming_wifi?
    pic_url = activity.pic_url(:large, host: host) || activity.default_pic_url

    items = [{title: activity.name, description: activity.summary, pic_url: pic_url, url: url}]
    Weixin.respond_news(@from_user_name, @to_user_name, items)
  end

  def respond_question
    @is_success = 2
    question = @mp_user.questions.search_keyword(@keyword) # 全匹配,或者模糊匹配中关键词相同的问题
    return respond_default_reply() unless question

    answer = question.answer
    case
      when answer.blank?          then respond_no_auto_reply()
      when answer.text?           then Weixin.respond_text(@from_user_name, @to_user_name, answer.content)
      when answer.activity?       then respond_activity(answer.replyable)
      when answer.graphic?        then respond_material_news(answer.replyable)
      when answer.audio_material? then Weixin.respond_music(@from_user_name, @to_user_name, answer.replyable)
      when answer.games?          then Weixin.respond_game(@from_user_name, @to_user_name, answer.replyable)
      else respond_no_auto_reply()
    end
  end

  def respond_no_auto_reply(content = '商家没有设置回复')
    @is_success = 0
    Weixin.respond_text(@from_user_name, @to_user_name, content)
  end

  def respond_activity_link(activity)
    return '' unless activity
    activity_notice = activity.activity_notices.active.first

    url = case
            when activity.website?               then mobile_root_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.vip?                   then app_vips_url(wxmuid: activity.wx_mp_user_id, openid: @wx_user.openid)
            when activity.consume?
              activity_notice = activity.activity_notices.first
              activity_consume = activity.activity_consumes.where(supplier_id: activity.supplier_id, wx_mp_user_id: activity.wx_mp_user_id, wx_user_id: @wx_user.id).first
              app_consume_url(activity_id: activity_notice.activity_id, id: activity_notice.id, code: activity_consume.try(:code), openid: @wx_user.openid)
            when activity.gua? && activity.setted?
              activity_notice = ActivityNotice.ready_or_active_notice(activity, [Activity::WARM_UP, Activity::HAS_ENDED])
              app_gua_url(activity, anid: activity_notice.id, wxmuid: activity.wx_mp_user_id, openid: @wx_user.openid, source: :notice)
            when activity.wheel? && activity.setted?
              activity_notice = ActivityNotice.ready_or_active_notice(activity)
              app_wheel_url(activity, anid: activity_notice.id, wxmuid: activity.wx_mp_user_id, openid: @wx_user.openid, source: :notice)
            when activity.book_dinner?           then book_dinner_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id,  openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.book_table?            then book_table_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id,  openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.fight?                 then app_fight_index_url(anid: activity_notice.id, aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id, m: 'index')
            when activity.take_out?              then take_out_mobile_shops_url(supplier_id: activity.supplier_id, aid: activity.id,  openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.enroll?                then new_app_activity_enroll_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.micro_store?           then mobile_micro_stores_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.vote?                  then mobile_vote_login_url(supplier_id: activity.supplier_id, vote_id: activity.id, openid: @wx_user.openid)
            when activity.house?                 then app_house_layouts_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.groups?                then app_activity_group_url(activity, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.surveys?               then respond_survey_activity_link(activity)
            when activity.car?                   then car_activity_url(activity)
            when activity.weddings?              then mobile_weddings_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, wid: activity.activityable_id)
            when activity.hotel?                 then "#{HOTEL_HOST}/wehotel-all/weixin/mobile/website.jsp?supplier_id=#{activity.supplier_id}&openid=#{@wx_user.openid}"
            when activity.album?                 then mobile_albums_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.educations?            then app_educations_url(cid: activity.activityable_id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.life?                  then app_lives_url(id: activity.activityable_id, aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.wshop? || activity.ec? then wshop_root_url(wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid))
            when activity.circle?                then app_business_circles_url(id: activity.activityable_id, aid: activity.id, wxmuid: activity.wx_mp_user_id)
            when activity.message?               then app_leaving_messages_url(aid: activity.id, wxmuid: activity.wx_mp_user_id)
            when activity.hit_egg?               then app_hit_egg_url(activity_notice.activity, openid: @wx_user.openid, wxmuid: activity_notice.wx_mp_user_id)
            when activity.house_bespeak?         then new_app_house_market_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_seller?          then app_house_sellers_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.slot?                  then app_slots_url(aid: activity_notice.activity_id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid)
            when activity.micro_aid?             then mobile_aids_url(activity_id: activity_notice.activity.id, supplier_id: activity.supplier_id, wxmuid: activity_notice.wx_mp_user_id, openid: @wx_user.openid)
            when activity.booking?               then mobile_supplier_booking_url(activity)
            when activity.group?                 then mobile_groups_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.trip?                  then mobile_trips_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.house_impression?      then app_house_impressions_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_live_photo?      then app_house_live_photos_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.house_intro?           then app_house_intros_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.ktv_order?             then app_ktv_orders_url(aid: activity.id, openid: @wx_user.openid, wxmuid: activity.wx_mp_user_id)
            when activity.wbbs_community?        then mobile_wbbs_topics_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.wmall?                 then wmall_root_url(wx_user_open_id: @wx_user.openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), supplier_id: activity.supplier_id)
            when activity.donation?              then mobile_donations_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, wid: activity.activityable_id, aid: activity.id)
            when activity.plot_bulletin?         then bulletins_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_repair?           then repair_complains_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid, type: 'repair')
            when activity.plot_complain?         then repair_complains_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid, type: 'complain')
            when activity.plot_telephone?        then telephones_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_owner?            then owners_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.plot_life?             then lives_mobile_wx_plots_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.coupon?                then mobile_coupons_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.reservation?           then mobile_reservations_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.wave?                  then mobile_waves_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.oa?                    then "#{OA_HOST}/woa-all/wx/#{activity.supplier_id}/index?openid=#{@wx_user.openid}"
            when activity.fans_game?             then mobile_fans_games_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.govmail?               then mobile_govmails_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.govchat?               then mobile_govchats_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.recommend?             then recommend_mobile_location(activity.id)
            when activity.unfold?                then mobile_unfolds_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.scene?                 then mobile_scenes_url(supplier_id: activity.supplier_id, aid: activity.id, openid: @wx_user.openid)
            when activity.panoramagram?          then mobile_supplier_panoramagram_url(activity)
            when activity.guess?                 then mobile_guess_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            when activity.brokerage?             then mobile_brokerages_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
            when activity.red_packet?            then mobile_red_packets_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
            else ''
          end
    [url, '#mp.weixin.qq.com'].join
  end

  def respond_survey_activity_link(activity)
    return '' unless activity
    activity_user = ActivityUser.where(wx_user_id: @wx_user.id, activity_id: activity.id).first
    return mobile_survey_url(supplier_id: activity.supplier_id, id: activity.id, openid: @wx_user.openid) if activity_user.nil? || !activity.setted?
    return success_mobile_survey_url(supplier_id: activity.supplier_id, id: activity.id, openid: @wx_user.openid) if activity_user.survey_finish?

    question = activity.activity_survey_questions.first
    question ? questions_mobile_survey_url(supplier_id: activity.supplier_id, id: activity.id, qid: question.id, openid: @wx_user.openid) : ''
  end

  def car_activity_url(activity)
    return Weixin.respond_text(@from_user_name, @to_user_name, '活动不存在') unless activity.activityable
    activity.car_url << "&openid=#{@wx_user.openid}"
  end

  def recommend_mobile_location(activity_id)
    if @mp_user.authorized_auth_subscribe?
      mobile_recommends_url(supplier_id: @mp_user.supplier_id, aid: activity_id)
    else
      mobile_recommends_url(supplier_id: @mp_user.supplier_id, aid: activity_id, openid: @from_user_name)
    end
  end

  def mobile_supplier_booking_url(activity)
    if BookingOrder.flow_suppliers.include?(activity.supplier_id)
      new_mobile_booking_order_url(supplier_id: activity.supplier_id)
    else
      mobile_bookings_url(supplier_id: activity.supplier_id, openid: @wx_user.openid)
    end
  end

  def mobile_supplier_panoramagram_url(activity)
    if activity.activityable_type == 'Panoramagram'
      panorama_mobile_panoramagram_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, id: activity.activityable_id)
    else
      mobile_panoramagrams_url(supplier_id: activity.supplier_id, openid: @wx_user.openid, aid: activity.id)
    end
  end
  
end
