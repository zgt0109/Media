class SmsAlidayu

  attr_accessor :result

  # 批量发送 mobiles是个数组
  def batchSend(sms_options = {}, options = {})
    self.result = send_sms(sms_options, options)
  end

  # 单次发送(用户名，密码，接收方号码，内容), 例如：singleSend('13599992222', '晚上有空么，小哥？', { userable_id: 1, userable_type: 'User', source: 'ec'})
  def singleSend(sms_options = {}, options = {})
    self.result = send_sms(sms_options, options)
  end

  def send_code_for_verify(mobiles, code, options = {})
    sms_options = { mobiles: mobiles, template_code: 'SMS_6770657', params: { code: code.to_s } }
    self.result = send_sms(sms_options, options)
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

  def send_sms(sms_options, options = {})
    content = sms_options[:template_code]
    mobiles = sms_options[:mobiles]
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
      # response = Alidayu::Sms.send_code_for_sign_up(content, mobiles)
      response = Alidayu::Sms.send(sms_options.merge!(mobiles: mobiles.to_s))
      WinwemediaLog::Base.logger('smslog', "response：#{response}")
      return_code = response['alibaba_aliqin_fc_sms_num_send_response']['result']['model'] rescue -999
      SmsLog.create(options.merge!(date: Date.today, phone: mobiles, content: content, provider: 'Alidayu', return_code: return_code))
    end

    self.result = return_code

    return_code
  end

end

# SmsAlidayu.new.singleSend('18621632985', 234569)
# SmsAlidayu.new.singleSend({ mobiles: '18621632985', template_code: 'SMS_6770657', params: { code: '234569' } })
