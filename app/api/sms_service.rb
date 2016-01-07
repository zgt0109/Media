class SmsService

  attr_accessor :result

  # 批量发送 mobiles是个数组
  def batchSend(mobiles, content, options = {})
    return false if mobiles.blank?
    return Rails.logger.info("短信内容：#{content}") if Rails.env.development?

    self.result = provider.new.batchSend(mobiles, content, options)
  end

  def singleSend(mobile, content, options = {})
    return false if mobile.blank?
    return Rails.logger.info("短信内容：#{content}") if Rails.env.development?

    self.result = provider.new.singleSend(mobile, content, options)
  end

  def balance
    self.result = provider.new.balance
  end

  def messages
    provider::MESSAGES
  end

  def provider
    # Settings.sms_service == 'zhilian' ? ZhilianSms : SmsApi
    provider = $redis.get('settings:sms:provider')
    case provider
    when 'songren'
      SongrenSms
    when 'fanmeng'
      FanmengSms
    when 'smsapi'
      SmsApi
    when 'emay'
      EmaySms
    else
      ZhilianSms
    end
  end

  def min_success_key_length
    provider.min_success_key_length
  end

  def error?
    return false if Rails.env.development?
    result.to_s.length < min_success_key_length
  end

  def error_message
    messages[result]
  end

end
