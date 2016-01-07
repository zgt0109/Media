class Weixin

  def self.print_request(xml)
    host = WEBSITE_DOMAIN

    word = xml[:Content]

    if word == '微打印'
      wx_user.small_machine_print!
      content = "<xml>
      <ToUserName><![CDATA[#{xml[:FromUserName]}]]></ToUserName>
      <FromUserName><![CDATA[#{xml[:ToUserName]}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[您已经进入打印模式，请发送图片给我。退出打印模式请回复：退出]]></Content>
      </xml>
      "
      return render text: content
    elsif word == '退出'
      wx_user.normal!
      content = "<xml>
      <ToUserName><![CDATA[#{xml[:FromUserName]}]]></ToUserName>
      <FromUserName><![CDATA[#{xml[:ToUserName]}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[您已经退出打印模式]]></Content>
      </xml>
      "
    end
  end

  def self.response_video(from_user_name, to_user_name, material)
    "<xml>
    <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
    <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
    <CreateTime>#{Time.now.to_i}</CreateTime>
    <MsgType><![CDATA[video]]></MsgType>
    <Video>
    <MediaId><![CDATA[10000001]]></MediaId>
    <ThumbMediaId><![CDATA[10000001]]></ThumbMediaId>
    </Video>
    </xml>"
  end

end

