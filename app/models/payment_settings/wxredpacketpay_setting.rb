class WxredpacketpaySetting < PaymentSetting
  self.inheritance_column = 'type'

  validates :partner_id, :partner_key, presence: true
  validates :api_client_cert, :api_client_key, presence: true

  def pay_options(red_packet_rec, action = 'send')
    red_packet = red_packet_rec.red_packet

    case action.to_s
    when 'send' 
      options = {
        'wxappid' => self.app_id,
        'mch_id'  => self.partner_id,
        'nonce_str' => generate_nonce_str,
        'mch_billno'    => red_packet_rec.out_trade_no,
        're_openid'     => red_packet_rec.uid,
        'total_amount'  => (red_packet_rec.total_amount * 100).to_i,
        'total_num'     => red_packet_rec.total_num,
        'nick_name'     => red_packet.nick_name[0,5],
        'send_name'     => red_packet.send_name[0,10],
        'min_value'     => (red_packet.min_value * 100).to_i,
        'max_value'     => (red_packet.max_value * 100).to_i,
        'wishing'       => red_packet.wishing,
        'act_name'      => red_packet.act_name[0,5],
        'remark'        => red_packet.remark,
        'logo_imgurl'   => red_packet.logo_imgurl,
        'share_content' => red_packet.share_content,
        'share_url'     => red_packet.share_url,
        'share_imgurl'  => red_packet.share_imgurl,
        'client_ip' => get_local_ip
      }
    when 'query'
      options = {
        'appid' => self.app_id,
        'mch_id'  => self.partner_id,
        'nonce_str' => generate_nonce_str,
        'mch_billno'    => red_packet_rec.out_trade_no,
        'bill_type' => 'MCHT'
      }
    end

    options
  end

  def get_sign(options, key = nil)
    sign_options = options.select do |k, v|
      v.present?   
    end 

    key ||= self.partner_key
   
    Digest::MD5.hexdigest(sign_options.sort.to_h.map { |k, v| "#{k}=#{v}" }.join('&') + "&key=#{key}").upcase 
  end

  def pay(red_packet_rec, action = 'send')
    options = pay_options red_packet_rec, action
    sign = get_sign options
    xml = create_xml options, sign 
   
    post_xml(action, xml) 
  end

  def query(red_packet_rec, action = 'query')
    options = pay_options red_packet_rec, action
    sign = get_sign options
    xml = create_xml options, sign 
   
    post_xml(action, xml)
  end

  def pay_url(action, options = {})
    case action.to_s
    when 'send'
      'https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack'
    when 'query'
      'https://api.mch.weixin.qq.com/mmpaymkttransfers/gethbinfo'
    end
  end

  def post_xml(action, xml)
    apiclient_cert =  cert_pem_to_x509(self.api_client_cert)
    apiclient_key = key_pem_to_rsa(self.api_client_key)
    conn = Faraday.new(ssl: {client_cert: apiclient_cert, client_key: apiclient_key}, headers: {'Content-Type' => 'application/xml'}) do |faraday|
      faraday.adapter Faraday.default_adapter
    end

    res = conn.post(pay_url(action), xml, {'Content-Type' => 'application/xml'})

    res
  end

  def create_xml(options, sign)
    options.merge!('sign' => sign)

    xml = '<xml>' + "\n"
 
    options.each do |k, v|
      xml += "<#{k}>"
      xml += "#{v}"
      xml += "</#{k}>" + "\n"
    end

    xml += '</xml>' 
  end

  private

  def generate_nonce_str
    str = 'winwemediaredpacket0123456789'
    (0 .. 31).map { str[rand(str.length)] }.join 
  end 
   
  def get_local_ip
    oring, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

    UDPSocket.open do |s|
      s.connect 'www.baidu.com', 1
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = oring 
  end

  def cert_pem_to_x509(cert_pem)
    cert_x509 = OpenSSL::X509::Certificate.new cert_pem
  end

  def key_pem_to_rsa(key_pem)
    key_rsa = OpenSSL::PKey::RSA.new key_pem
  end

end
