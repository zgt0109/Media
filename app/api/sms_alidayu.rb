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

  # sms_options = {
  #   mobiles: '18621632985',
  #   template_code: 'SMS_6770657',
  #   params: {
  #     code: '234569',
  #     product: '微枚迪'
  #   }
  # }
  # # params为模板内容的变量集合，根据模板中定义变量的不同而不同，若模板中未定义变量可不传
  # Alidayu::Sms.send(sms_options)
  #
  # options: source, account_id, site_id, userable_id, userable_type
  # source 业务类型(1:会员卡,2:电商,3:餐饮,4:酒店,5:小区,6:活动,7:微服务,8:其它)
  def send_sms(sms_options, options = {})
    content = sms_options[:template_code]
    mobiles = sms_options[:mobiles]

    if mobiles.is_a?(Array)
      mobiles_count = mobiles.count
      mobiles = mobiles.join(',')
    else
      mobiles_count = mobiles.split(',').count
    end

    # today_send_count = SmsLog.where(date: Date.today, phone: mobiles).count
    # if today_send_count > 20
    #   Rails.logger.info("手机号码：#{mobiles} 今天短信发送次数：#{today_send_count}")
    #   SiteLog::Base.logger('smslog', "手机号码：#{mobiles} 今天短信发送次数：#{today_send_count}")

    #   return_code = -1
    # else

      # SiteLog::Base.logger('smslog', "request: #{sms_options}")

      response = Alidayu::Sms.send(sms_options.merge!(mobiles: mobiles.to_s))
      SiteLog::Base.logger('smslog', "request: #{sms_options}, response：#{response}")

      return_code = response['alibaba_aliqin_fc_sms_num_send_response']['result']['model'] rescue -1
      SmsLog.create(options.merge!(date: Date.today, phone: mobiles, content: content, provider: 'Alidayu', return_code: return_code))
    # end

    self.result = return_code

    return_code
  end

end

# SmsAlidayu.new.singleSend('18621632985', 234569)
# SmsAlidayu.new.singleSend({ mobiles: '18621632985', template_code: 'SMS_6770657', params: { code: '234569' } })
