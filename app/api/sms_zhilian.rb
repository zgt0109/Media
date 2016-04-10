require 'savon'
# 直连WEBSERVICE接口
# string userId, string password, string pszMobis, string pszMsg, int iMobiCount, string pszSubPort
class SmsZhilian
  MESSAGES = {
    -1 =>  '参数为空。信息、电话号码等有空指针，登陆失败',
    -2 =>  '电话号码个数超过100',
    -10 => '申请缓存空间失败',
    -11 => '电话号码中有非数字字符',
    -12 => '有异常电话号码',
    -13 => '电话号码个数与实际个数不相等',
    -14 => '实际号码个数超过100',
    -101 =>  '发送消息等待超时',
    -102 =>  '发送或接收消息失败',
    -103 =>  '接收消息超时',
    -200 =>  '其他错误',
    -999 =>  'web服务器内部错误',
    -999 =>  '服务器内部错误',
    -10001 =>  '用户登陆不成功(帐号不存在/停用/密码错误)',
    -10002 =>  '提交格式不正确',
    -10003 =>  '用户余额不足',
    -10004 =>  '手机号码不正确',
    -10005 =>  '计费用户帐号错误',
    -10006 =>  '计费用户密码错',
    -10007 =>  '账号已经被停用',
    -10008 =>  '账号类型不支持该功能',
    -10009 =>  '其它错误',
    -10010 =>  '企业代码不正确',
    -10011 =>  '信息内容超长',
    -10012 =>  '不能发送联通号码',
    -10013 =>  '操作员权限不够',
    -10014 =>  '费率代码不正确',
    -10015 =>  '服务器繁忙',
    -10016 =>  '企业权限不够',
    -10017 =>  '此时间段不允许发送',
    -10018 =>  '经销商用户名或密码错',
    -10019 =>  '手机列表或规则错误',
    -10021 =>  '没有开停户权限',
    -10022 =>  '没有转换用户类型的权限',
    -10023 =>  '没有修改用户所属经销商的权限',
    -10024 =>  '经销商用户名或密码错',
    -10025 =>  '操作员登陆名或密码错误',
    -10026 =>  '操作员所充值的用户不存在',
    -10027 =>  '操作员没有充值商务版的权限',
    -10028 =>  '该用户没有转正不能充值',
    -10029 =>  '此用户没有权限从此通道发送信息(用户没有绑定该性质的通道，比如：用户发了小灵通的号码)',
    -10030 =>  '不能发送移动号码',
    -10031 =>  '手机号码(段)非法',
    -10032 =>  '用户使用的费率代码错误',
    -10033 =>  '非法关键词'
  }

  def self.client
    @client ||= Savon.client(wsdl: Settings.zhilian_url)
  end


  # 批量发送 mobiles是个数组
  def batchSend(mobiles, content, options = {})
    send_sms(mobiles, content, options)
  end

  # 单次发送(用户名，密码，接收方号码，内容), 例如：singleSend('13599992222', '晚上有空么，小哥？', { userable_id: 1, userable_type: 'User', source: 'ec'})
  def singleSend(mobile, content, options = {})
    send_sms(mobile, content, options)
  end

  def self.min_success_key_length
    5
  end

  def balance
     response = SmsZhilian.client.call(:mongate_query_balance) do
      message userId: Settings.zhilian_user_id, password: Settings.zhilian_password
    end
    result = response.body[:mongate_query_balance_response]
    result.merge!(overage: result[:mongate_query_balance_result])
    result
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
      CustomLog::Base.logger('smslog', "手机号码：#{mobiles} 今天短信发送次数：#{today_send_count}")

      return_code = -999
    else
      response = SmsZhilian.client.call(:mongate_cs_sp_send_sms_new) do
        message userId: Settings.zhilian_user_id, password: Settings.zhilian_password, pszMobis: mobiles,pszMsg: content,iMobiCount: mobiles_count, pszSubPort: '****'
      end
      return_code = response.body[:mongate_cs_sp_send_sms_new_response][:mongate_cs_sp_send_sms_new_result].to_i rescue -999
      SmsLog.create(options.merge!(date: Date.today, phone: mobiles, content: content, provider: self.class.to_s, return_code: return_code))
    end

    return_code
  end

end
