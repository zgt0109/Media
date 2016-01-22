class Weixin
  NO_GAME_TEXT = '游戏不存在或商户未开启此游戏'

  class << self

    def encrypt_msg(decrypted_string)
      #encrypt_type, wx_mp_user, app_id, 
      return decrypted_string unless $encrypt_type.eql?('aes')
      attrs = {
        encoding_aes_key: $app_id.present? ? Settings.wx_plugin.encoding_aes_key : $wx_mp_user.encoding_aes_key,
        token: $app_id.present? ? Settings.wx_plugin.token : $wx_mp_user.token,
        app_id: $app_id.present? ? Settings.wx_plugin.component_app_id : $wx_mp_user.app_id,
        decrypted_string: decrypted_string
      }
      return decrypted_string if attrs[:encoding_aes_key].blank?
      aes = WeixinAes.new(attrs)
      aes.encrypt_msg
    end

    def respond_text(from_user_name, to_user_name, message)
      return '' if message.blank?
      msg = "<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[#{message[0, 500]}]]></Content>
      </xml>"
      encrypt_msg(msg)
    end

    def respond_news(from_user_name, to_user_name, items)
      wx_mp_user = WxMpUser.where(openid: to_user_name).first
      if wx_mp_user.try(:is_oauth?)
        items.each do |item|
          item[:url] = item[:url].to_s.gsub('openid', 'origin_openid') unless item[:url].to_s =~ /wehotel|woa/
        end
        items
      end

      msg = "<xml>
        <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
        <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
        <CreateTime>#{Time.now.to_i}</CreateTime>
        <MsgType><![CDATA[news]]></MsgType>
        <ArticleCount>#{items.count}</ArticleCount>
        <Articles>
          #{items_xml(items)}
        </Articles>
      </xml>"
      encrypt_msg(msg)
    end

    def respond_music(from_user_name, to_user_name, material)
      host = WWW_HOST
      msg = "<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[music]]></MsgType>
      <Music>
      <Title><![CDATA[#{material.audio.try(:file).try(:filename)}]]></Title>
      <Description><![CDATA[]]></Description>
      <MusicUrl><![CDATA[#{material.audio_absolute_path(host)}]]></MusicUrl>
      <HQMusicUrl><![CDATA[#{material.audio_absolute_path(host)}]]></HQMusicUrl>
      </Music>
      </xml>"
      encrypt_msg(msg)
    end

    def respond_music_content(from_user_name, to_user_name, content)
      %Q(<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[music]]></MsgType>
      #{content}
      </xml>)
    end

    def respond_video(from_user_name, to_user_name, material)
      msg = "<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[video]]></MsgType>
      <Video>
      <MediaId><![CDATA[10000001]]></MediaId>
      <ThumbMediaId><![CDATA[10000001]]></ThumbMediaId>
      </Video>
      </xml>"
      encrypt_msg(msg)
    end


    def respond_album(from_user_name, to_user_name, album)
      url = "#{M_HOST}/#{album.supplier_id}/albums/#{album.id}/list?aid=#{album.activity_id}&openid=#{from_user_name}"
      msg = "<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[news]]></MsgType>
      <ArticleCount>1</ArticleCount>
      <Articles>
      <item>
      <Title><![CDATA[#{album.name}]]></Title>
      <Description><![CDATA[]]></Description>
      <PicUrl><![CDATA[#{album.cover_picture}]]></PicUrl>
      <Url><![CDATA[#{url}]]></Url>
      </item>
      </Articles>
      </xml>"
      encrypt_msg(msg)
    end

    def respond_game(from_user_name, to_user_name, game)
      content = game ? %Q(<a href="#{game.url}">#{game.name}</a>) : NO_GAME_TEXT
      respond_text(from_user_name, to_user_name, content)
    end

    def respond_dkf(from_user_name, to_user_name)
      msg = "<xml>
      <ToUserName><![CDATA[#{from_user_name}]]></ToUserName>
      <FromUserName><![CDATA[#{to_user_name}]]></FromUserName>
      <CreateTime>#{Time.now.to_i}</CreateTime>
      <MsgType><![CDATA[transfer_customer_service]]></MsgType>
      </xml>"
      encrypt_msg(msg)
    end

    def get_wx_user_info(wx_mp_user, openid, third_access_token = nil)
      wx_mp_user.auth! if wx_mp_user.present?
      if third_access_token.present?
        access_token = third_access_token
        url = "https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"

        fields = %w[subscribe nickname sex language city province country headimgurl subscribe_time]
        res = HTTParty.get(url)
        hash = JSON res.body
        hash = hash.to_h.slice(*fields)
      else
        access_token = wx_mp_user.access_token
        url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"

        fields = %w[subscribe nickname sex language city province country headimgurl subscribe_time]
        hash = HTTParty.post(url).to_h.slice(*fields)
      end

      hash.merge!('subscribe_time' => Time.at(hash['subscribe_time'])) if hash['subscribe_time']
      hash
    rescue => e
      Rails.logger.error "*********************************get_wx_user_info error: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end

    private
      def items_xml(items)
        items.map do |item|
          "<item>
            <Title><![CDATA[#{item[:title]}]]></Title>
            <Description><![CDATA[#{item[:description]}]]></Description>
            <PicUrl><![CDATA[#{item[:pic_url]}]]></PicUrl>
            <Url><![CDATA[#{item[:url]}]]></Url>
          </item>"
        end.join("\n")
      end

  end

end

