require 'open-uri'
class GreetVoice < ActiveRecord::Base
  belongs_to :wx_user

  def sound_name
    self.name.presence || '未知'
  end

  def self.respond_greet_voice(wx_user, wx_mp_user, keyword)
    user_voice = wx_user.user_voices.last
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '请先发送语音') unless user_voice

    user_voice.update_attributes(name: keyword)
    greet_activity = wx_mp_user.supplier.greets.first.activity
    url = "#{MOBILE_DOMAIN}/#{wx_mp_user.supplier_id}/greet_cards?activity_id=#{greet_activity.id}&openid=#{wx_user.openid}"
    pic_url = qiniu_image_url(greet_activity.pic_key) || "#{MOBILE_DOMAIN}#{greet_activity.try(:pic).try(:large)}"

    items = [{title: greet_activity.name, description: greet_activity.summary, pic_url: pic_url, url: url}]
    Weixin.respond_news(wx_user.openid, wx_mp_user.openid, items)
  end

  def self.respond_voice(wx_user, wx_mp_user, xml)
    return Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '授权失败，请确保应用ID和应用匹配') unless wx_mp_user.auth! # 确保access_token要最新,不然调用不到下载

    user_voice  = wx_user.user_voices.new
    if user_voice.save_from_xml(wx_mp_user, xml)
      Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '输入汉字"语音"+语音名称,如:语音新年快乐')
    else
      Weixin.respond_text(wx_user.openid, wx_mp_user.openid, '上传语音失败，请重新录制')
    end
  end

  def save_from_xml(wx_mp_user, xml)
    media_id    = xml[:MediaId] #(媒体 ID,需要调用接口下载)
    recognition = xml[:Recognition] # 语音识别结果(utf-8)
    media_url   = "http://file.api.weixin.qq.com/cgi-bin/media/get?access_token=#{wx_mp_user.access_token}&media_id=#{media_id}"
    self.name             = recognition
    self.media_id         = media_id
    self.description      = media_url
    self.remote_sound_url = media_url
    save!
  rescue => e
    WinwemediaLog::Base.logger('wx_api', "Voice receive fail: #{e.message} -> #{e.backtrace}")
    false
  end
end
