require 'net/http'
require "rexml/document"

class SmsApi
  include REXML

  attr_accessor :sn, :pwd

  MESSAGES = {
    1 => "没有需要取得的数据 取用户回复就出现1的返回值,表示没有回复数据",
    -1 =>"重复注册 多次点击“注册”按钮或注册方法（Register）的“调用”按钮",
    -2 =>"帐号/密码不正确 1.序列号未注册2.密码加密不正确3.密码已被修改4.序列号已注销",
    -4 =>"余额不足支持本次发送 直接调用查询看是否余额为0或不足",
    -5 =>"数据格式错误 只能自行调试了。或与技术支持联系",
    -6 =>"参数有误 看参数传的是否均正常,请调试程序查看各参数",
    -7 =>"权限受限 该序列号是否已经开通了调用该方法的权限",
    -8 =>"流量控制错误",
    -9 =>"扩展码权限错误 该序列号是否已经开通了扩展子号的权限,把ext这个参数置空。",
    -10 => "内容长度长 短信内容过长，纯单字节不能超过1000个，双字节不能超过500个字符2.彩信不得超过50KB",
    -11 => "内部数据库错误",
    -12 => "序列号状态错误 序列号是否被禁用",
    -13 => "没有提交增值内容 提交时，无文本或无图片",
    -14 => "服务器写文件失败",
    -15 => "文件内容base64编码错误",
    -16 => "返回报告库参数错误",
    -17 => "没有权限 如发送彩信仅限于SDK3",
    -18 => "上次提交没有等待返回不能继续提交默认不支持多线程",
    -19 => "禁止同时使用多个接口地址 每个序列号提交只能使用一个接口地址",
    -20 => "相同手机号，相同内容重复提交",
    -22 => "Ip鉴权失败 提交的IP不是所绑定的IP"
  }

  # http://self.zucp.net/
  def initialize
    self.sn = "SDK-WSS-010-05925"
    self.pwd = "123456"
  end

  # 批量发送 numbers是个数组
  def batchSend (numbers, content, options = {})
    params = defaultParams( numbers, content)
    data = send(params)
    puts "data ************* #{data}"
    # WinwemediaLog::SmsApi.add("sms api batchSend data: #{data}")
    body = parseResBody data.body
    ret = body.to_i
    SmsLog.create(options.merge!(date: Date.today, phone: numbers.join(','), content: content, provider: self.class.to_s, return_code: ret))
    message = MESSAGES[ret]
    # WinwemediaLog::SmsApi.add("sms api batchSend error message: #{message}")
    ret
  rescue => e
     # WinwemediaLog::SmsApi.add("sms api batchSend error message: #{e}")
    -100
  end

  # 单次发送(用户名，密码，接收方号码，内容)
  def singleSend (number, content, options = {})
    params = defaultParams( number.split, content)
    data = send(params)
    puts "data ************* #{data}"
    # WinwemediaLog::SmsApi.add("sms api singleSend data: #{data}")
    body = parseResBody data.body
    ret =  body.to_i
    SmsLog.create(options.merge!(date: Date.today, phone: number, content: content, provider: 'SmsApi', return_code: ret))
    message = MESSAGES[ret]
    # WinwemediaLog::SmsApi.add("sms api batchSend error message: #{message}")
    ret
  #rescue => e
     # WinwemediaLog::SmsApi.add("sms api batchSend error message: #{e}")
    #-100
  end

  def balance
    params = { sn: self.sn, pwd: self.pwd }
    data = Net::HTTP.post_form(URI.parse("http://sdk2.zucp.net:8060/webservice.asmx/balance?sn=#{self.sn}&pwd=#{self.pwd}"), params)
    body = parseResBody data.body
    ret =  body.to_i
    puts ret # eg: -6
    ret
  end

  def self.min_success_key_length
    4
  end

  private

    def md5password (sn, pwd)
      require 'digest'
      Digest::MD5.hexdigest("#{sn}#{pwd}").upcase
    end

    def parseResBody string
      doc = Document.new(string)
      root = doc.root
      root.text
    end

    def defaultParams( numbers, content)
      params = {}
      content = content + "【微枚迪】"
      params["sn"] = sn
      params["pwd"] = md5password(sn, pwd)
      params["mobile"] = numbers.join(',')
      params["content"] = content.encode('gb2312') rescue ''
      params["ext"] = "" #Time.now.to_i
      params["stime"] = ""
      params["rrid"] = ""
      # params["sign"] = "winwemedia"
      return params
    end

    def send params
      Net::HTTP.post_form(URI.parse('http://sdk2.zucp.net:8060/webservice.asmx/mt'), params)
    end
end

#s = SmsApi.new
#s.singleSend("13052359606","hello world 你好世界")
