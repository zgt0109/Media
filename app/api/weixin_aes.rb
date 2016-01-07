# -*- encoding : utf-8 -*-
class WeixinAes

  attr_accessor :encoding_aes_key, :token, :timestamp, :nonce, :app_id, :msg_signature, :encrypted_string, :decrypted_string

  def initialize(options = {})
    options.each{|k, v| self.send("#{k.to_s}=", v) }
  end

  def decrypt_string
    aes_key            = Base64.decode64(encoding_aes_key + '=')
    aes_encoded_msg    = Base64.decode64(encrypted_string)
      
    de_cipher          = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
    de_cipher.decrypt
    de_cipher.padding  = 0
    de_cipher.key      = aes_key
    de_cipher.iv       = aes_key[0, 16]

    self.decrypted_string  = "#{de_cipher.update(aes_encoded_msg)}#{de_cipher.final}"
  end

  def hash_from_encrypt
    last_right_angle_index = decrypted_string.rindex('>')
    hash = HashWithIndifferentAccess.new(Hash.from_xml(decrypted_string[20..last_right_angle_index]))
    hash[:app_id] = decrypted_string[(last_right_angle_index + 1)..-1]
    hash
  end

  def signature_valid?(params)
    msg_signature    = params['msg_signature']
    timestamp        = params['timestamp']
    nonce            = params['nonce']
    encrypted_string = params['xml']['Encrypt']

    msg_signature == generate_signature
  end

  def encrypt_msg
    self.timestamp      ||= Time.now.to_i.to_s
    self.nonce          ||= Time.now.to_i.to_s.reverse
    msg                   = decrypted_string.force_encoding('ascii-8bit')
    msg                   = kcs7_encoder("#{SecureRandom.hex(8)}#{[msg.size].pack('N')}#{msg}#{app_id}")
    self.encrypted_string = aes_encrypt(msg)
    self.msg_signature    = generate_signature
    "<xml>
       <Encrypt><![CDATA[#{self.encrypted_string}]]></Encrypt>
       <MsgSignature><![CDATA[#{self.msg_signature}]]></MsgSignature>
       <TimeStamp><![CDATA[#{self.timestamp}]]></TimeStamp>
       <Nonce><![CDATA[#{self.nonce}]]></Nonce>
     </xml>"
  end

  def aes_encrypt(msg)
    aes_key           = Base64.decode64(encoding_aes_key + '=')
    en_cipher         = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
    en_cipher.encrypt
    en_cipher.padding = 0
    en_cipher.key     = aes_key
    en_cipher.iv      = aes_key[0, 16]
    Base64.encode64("#{en_cipher.update(msg)}#{en_cipher.final}")
  end
    
  def generate_signature
    Digest::SHA1.hexdigest([token, timestamp, nonce, encrypted_string].sort.join)
  end
    
  def host_to_network_order(int_value, fill = 0)
    int_value.to_s(16).rjust(fill, '0').split('').each_slice(2).to_a.map{|a| [a.join].pack('H*')}.join('')
  end

  def kcs7_encoder(msg)
    block_size = 32
    amount_to_pad = block_size - (msg.length % block_size)
    amount_to_pad = block_size if amount_to_pad == 0
    pad = amount_to_pad.chr
    "#{msg}#{pad * amount_to_pad}"
  end

end
