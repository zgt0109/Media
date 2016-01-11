class WxUserInfoUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: true, backtrace: true

  def self.fetch_and_save_user_info(wx_user, wx_mp_user)
    if wx_mp_user.can_fetch_wx_user_info? && !wx_user.has_info?
      WxUserInfoUpdateWorker.perform_async(wx_mp_user.openid, wx_user.openid)
    end
  end

  def self.fetch_and_save_user_info!(wx_user, wx_mp_user)
    if wx_mp_user.can_fetch_wx_user_info? && !wx_user.has_info?
      WxUserInfoUpdateWorker.new.perform(wx_mp_user.openid, wx_user.openid)
    end
  rescue => e
    Rails.logger.error "-----------------fetch_and_save_user_info! error:#{e.message}"
    e.backtrace.each do |message|
      Rails.logger.error message
    end
  end

  def self.fetch_and_save_user_info_unconditional!(wx_user, wx_mp_user)
    if wx_mp_user.can_fetch_wx_user_info?
      WxUserInfoUpdateWorker.new.perform(wx_mp_user.openid, wx_user.openid)
    end
  rescue => e
    Rails.logger.error "-----------------fetch_and_save_user_info_unconditional! error:#{e.message}"
    e.backtrace.each do |message|
      Rails.logger.error message
    end
  end

  def perform(mp_user_openid, openid)
    mp_user = WxMpUser.where(openid: mp_user_openid).first
    return unless mp_user
    wx_user = mp_user.wx_users.where(openid: openid).first
    return if wx_user.nil? || wx_user.nickname.present?

    if mp_user.try(:can_fetch_wx_user_info?)
      attrs = Weixin.get_wx_user_info(mp_user, wx_user.openid)
      return unless attrs
      wx_user.update_attributes(attrs) if attrs['subscribe'] != 0
    end
  end

end
