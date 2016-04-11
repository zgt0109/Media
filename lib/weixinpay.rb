def generate_noce_str
  str = "site0123456789"
  (0...32).map { str[rand(str.length)] }.join
end

def get_sign sign_params = [], key=''
  Digest::MD5.hexdigest(sign_params.sort.join('&') +  "&key=#{key}").upcase
end

def create_xml request_options = {}, sign = ''
  "<xml>
      <appid>#{request_options[:appid]}</appid>
      <mch_id>#{request_options[:mch_id]}</mch_id>
      <nonce_str>#{request_options[:nonce_str]}</nonce_str>
      <sign><![CDATA[#{sign}]]></sign>
      <body><![CDATA[#{request_options[:body]}]]></body>
      <out_trade_no>#{request_options[:out_trade_no]}</out_trade_no>
      <total_fee>#{request_options[:total_fee]}</total_fee>
      <spbill_create_ip>#{request_options[:spbill_create_ip]}</spbill_create_ip>
      <notify_url>#{request_options[:notify_url]}</notify_url>
      <trade_type>#{request_options[:trade_type]}</trade_type>
      <openid>#{request_options[:openid]}</openid>
   </xml>"
end

def request_unifiedorder xml = ''
  request_url = "https://api.mch.weixin.qq.com/pay/unifiedorder"	
  HTTParty.post(request_url,body:xml, headers:{'ContentType' => 'application/xml'} )
end

def get_sign_type
  "MD5"
end

def get_time_stamp
  Time.now.to_i.to_s
end

def set_sign_params request_options = {}
  ["appid=#{request_options[:appid]}", "mch_id=#{request_options[:mch_id]}", "nonce_str=#{request_options[:nonce_str]}", "body=#{request_options[:body]}", "out_trade_no=#{request_options[:out_trade_no]}", "total_fee=#{request_options[:total_fee]}","spbill_create_ip=#{request_options[:spbill_create_ip]}", "notify_url=#{request_options[:notify_url]}", "trade_type=#{request_options[:trade_type]}", "openid=#{request_options[:openid]}"]
end

def write_weixinv2_log result = ""
  SiteLog::Base.logger('wxpay', result)
end

def write_wxredpacket_log(info = '')
  SiteLog::Base.logger('wxredpacketpay', info)
end

def notify_result result = ''
  "<xml>
    <return_code><![CDATA[#{result}]]></return_code>
    <return_msg><![CDATA[#{result}]]></return_msg>
  </xml>"
end
