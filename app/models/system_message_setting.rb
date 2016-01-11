class SystemMessageSetting < ActiveRecord::Base

  belongs_to :site
  belongs_to :system_message_module
  has_many :system_messages

  def music
    voice? ? voice.to_s : '/music/system_messages_default.mp3' if is_open_voice
  end

  def view_remind_music
    uri = URI.parse("http://#{FAYE_HOST}/faye")
    Net::HTTP.post_form(uri, message: {channel: "/system_messages/change/#{supplier_id}", data: {operate: 'play', music: music}}.to_json)
  end

end