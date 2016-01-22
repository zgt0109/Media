class WeixinKefu

  def self.request(params, mp_user)
    params.merge!({token: mp_user.kefu_token})
    host = WWW_HOST

    xml = params[:xml]
    wx_user = mp_user.wx_users.where(openid: xml[:FromUserName]).first
    word = xml[:Content]
    response_content = ''

    if word == mp_user.kefu_enter_command
      wx_user.kefu!

      post_message_to_kefu(xml, params, mp_user, true)
    elsif word == mp_user.kefu_quit_command && wx_user.try(:kefu?)
      wx_user.kefu_rate!
      post_message_to_kefu(xml, params)
    elsif wx_user.try(:kefu?)
      wx_user.update_attributes(match_at: Time.now)
      post_message_to_kefu(xml, params, mp_user)
    elsif wx_user.try(:kefu_rate?)
      if wx_user.match_at.ago(-1.minutes) > Time.now
        post_message_to_kefu(xml, params.merge(:rate => true))
      else
        wx_user.normal!
      end
    else
      #response(xml.merge(:Content => '请求失败'))
      response_content = 'normal_match'
    end
    response_content
  end

  def self.response(xml)
    return '' if xml && xml[:Content].blank?

    "<xml>
    <ToUserName><![CDATA[#{xml[:FromUserName]}]]></ToUserName>
    <FromUserName><![CDATA[#{xml[:ToUserName]}]]></FromUserName>
    <CreateTime>#{Time.now.to_i}</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>
    <Content><![CDATA[#{xml[:Content]}]]></Content>
    </xml>
    "
  end

  def self.post_message_to_kefu(xml, params, mp_user=nil, send_user_info=false)
    begin
      PostMessageToKefuWorker.perform_async(xml, params, mp_user.try(:id), send_user_info)
    rescue => error
      response(xml.merge(:Content => "传输数据失败:#{error.backtrace}"))
    end
  end

  def self.post_user_info_to_kefu(mp_user, user_openid)
    PostUserInfoToKefuWorker.perform_async(mp_user.id, user_openid)
  end

  def self.location_request(params, mp_user)
    params.merge!({token: mp_user.kefu_token})
    xml = params[:xml]
    post_message_to_kefu(xml, params)
  end

end

