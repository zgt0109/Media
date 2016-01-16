require "rexml/document"

class EmaySms
  
  include REXML

  attr_accessor :cdkey, :password, :api_base_url, :api_base_params

  MESSAGES = {
        0 => '成功',
       -1 => '系统异常',
     -101 => '命令不被支持',
     -102 => '用户信息删除失败',
     -103 => '用户信息更新失败',
     -104 => '指令超出请求限制',
     -111 => '企业注册失败',
     -117 => '发送短信失败',
     -118 => '获取MO失败',
     -119 => '获取Report失败',
     -120 => '更新密码失败',
     -122 => '用户注销失败',
     -110 => '用户激活失败',
     -123 => '查询单价失败',
     -124 => '查询余额失败',
     -125 => '设置MO转发失败',
     -127 => '计费失败零余额',
     -128 => '计费失败余额不足',
    -1100 => '序列号错误,序列号不存在内存中,或尝试攻击的用户',
    -1102 => '序列号正确,Password错误',
    -1103 => '序列号正确,Key错误',
    -1104 => '序列号路由错误',
    -1105 => '序列号状态异常 未用1',
    -1106 => '序列号状态异常 已用2 兼容原有系统为0',
    -1107 => '序列号状态异常 停用3',
    -1108 => '序列号状态异常 停止5',
     -113 => '充值失败',
    -1131 => '充值卡无效',
    -1132 => '充值卡密码无效',
    -1133 => '充值卡绑定异常',
    -1134 => '充值卡状态异常',
    -1135 => '充值卡金额无效',
     -190 => '数据库异常',
    -1901 => '数据库插入异常',
    -1902 => '数据库更新异常',
    -1903 => '数据库删除异常',
  }

  def initialize
    self.cdkey = '9SDK-EMY-0999-JDUQN'
    self.password = '101006'
    self.api_base_url = 'http://sdk999ws.eucp.b2m.cn:8080/sdkproxy'
    self.api_base_params = {
      cdkey: cdkey,
      password: password,
    }
  end

  def batchSend(mobiles, message, options={})
    send_sms(mobiles, message, options)
  end

  def singleSend(mobile, message, options={})
    send_sms(mobile, message, options)
  end

  def parseResBody string
    doc = Document.new(string)
    root = doc.root
    root.elements
  end

  def balance
    resp = HTTParty.post "#{api_base_url}/querybalance.action?#{api_base_params.to_query}"
    elements = parseResBody(resp.body)
    return elements['//message'].text.to_f
  end

  def send_sms(mobiles, message, options={})
    params = api_base_params.merge(
      phone: Array(mobiles).join(","),
      message: message,
      addserial: "【微枚迪】"
    )
    resp = HTTParty.post "#{api_base_url}/sendsms.action?#{params.to_query}"
    elements = parseResBody(resp.body)
    error = elements['//error'].text.to_i
    SmsLog.create(options.merge!(date: Date.today, phone: Array(mobiles).join(","), content: message, provider: self.class.to_s, return_code: error))
    error.zero? ? 10 : 1
  end

  def self.min_success_key_length
    1
  end

end
