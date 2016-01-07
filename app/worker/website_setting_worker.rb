class WebsiteSettingWorker
  include Sidekiq::Worker
  sidekiq_options :queue => 'website_setting', :retry => false, :backtrace => true

  def perform(website_setting_id)
    website_setting = WebsiteSetting.where(id: website_setting_id).first
    website_setting.try(:upload_bg_music_to_qiniu)
  end

end
