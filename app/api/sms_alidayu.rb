class SmsAlidayu

  attr_accessor :result

  # 批量发送 mobiles是个数组
  def batchSend(mobiles, content, options = {})
    self.result = send_sms(mobiles, content, options)
  end

  # 单次发送(用户名，密码，接收方号码，内容), 例如：singleSend('13599992222', '晚上有空么，小哥？', { userable_id: 1, userable_type: 'User', source: 'ec'})
  def singleSend(mobile, content, options = {})
    self.result = send_sms(mobile, content, options)
  end

  def self.min_success_key_length
    5
  end

  def balance
    {}
  end

  def error_message
    {}
  end

  def error?
    false
  end

  def send_sms(mobiles, content, options = {})
    if mobiles.is_a?(Array)
      mobiles_count = mobiles.count
      mobiles = mobiles.join(',')
    else
      mobiles_count = mobiles.split(',').count
    end

    today_send_count = SmsLog.where(date: Date.today, phone: mobiles).count
    if today_send_count > 20
      Rails.logger.info("手机号码：#{mobiles} 今天短信发送次数：#{today_send_count}")
      WinwemediaLog::Base.logger('smslog', "手机号码：#{mobiles} 今天短信发送次数：#{today_send_count}")

      return_code = -999
    else
      # Alidayu::Sms.send_code_for_sign_up(1314520, "18621632985")
      response = Alidayu::Sms.send_code_for_sign_up(content, mobiles)
      return_code = response['alibaba_aliqin_fc_sms_num_send_response']['result']['model'] rescue -999
      SmsLog.create(options.merge!(date: Date.today, phone: mobiles, content: content, provider: 'Alidayu', return_code: return_code))
    end

    return_code
  end

end

# SmsAlidayu.new.singleSend('18621632985', 234569)