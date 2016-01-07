# encoding: utf-8
class YeepayLib::Crypto
  # usage:
  # install pip
  # http://www.gowhich.com/blog/346
  # yum install python-devel openssl-devel
  #
  # sudo pip install pyOpenSSL crypto pycrypto
  # payment_yeepay = YeepayLib::Crypto.new
  # fetch encypted data
  # data = payment_yeepay.encypt_pay_credit_data
  # uri = URI("http://ok.yeepay.com/paymobile/api/pay/request")
  # uri.query= data.to_param
  # uri
  # send an encypted request and decypted data from yeepay
  # payment_yeepay.bind_pay_async
  # decrype data from yeepay eg. payment callback
  # query_hash = Rack::Utils.parse_query(uri.query)
  # query_hash
  # payment_yeepay = YeepayLib::Crypto.new
  # payment_yeepay.decypt_data(query_hash)

  include YeepayLib::Interface

  # test yeepay interface
  attr_accessor :merchant_public_key, :merchant_private_key,
                :yeepay_public_key, :merchantaccount,
                :yeepay_host, :default_params, :py_crypto_path

  # you can supply :merchant_private_key, :merchant_public_key, :yeepay_public_key
  # :merchantaccount, :yeepay_host
  def initialize(options = {}, default_params = {})
    options = HashWithIndifferentAccess.new(options)
    default_params = HashWithIndifferentAccess.new(default_params)

    @merchant_private_key = self.class.merchant_private_key(options[:merchant_private_key])
    @merchant_public_key = self.class.merchant_public_key(options[:merchant_public_key])
    @yeepay_public_key = self.class.yeepay_public_key(options[:yeepay_public_key])
    @merchantaccount = options[:merchantaccount] || 'YB01000000144'
    @yeepay_host = options[:yeepay_host] || "http://ok.yeepay.com/"

    # default_params will send to yeepay
    @default_params = {
                        merchantaccount: @merchantaccount,
                        callbackurl: default_params[:callbackurl],
                        fcallbackurl: default_params[:fcallbackurl]
                      }

    #
    @py_crypto_path = Rails.root.join("lib/yeepay_lib", 'yeepay_crypto.py')
  end

  delegate :generate_order_no, to: YeepayLib::Crypto

  def default_params
    @default_params.dup
  end

  # store crypto_data to temp file
  # payment_data = {request_data: request_data, response_data: response_data}
  # :request_data or :response_data must been provided
  #
  def store_crypto_data_to_file(payment_data = {})
    payment_data = HashWithIndifferentAccess.new(payment_data)
    return  if payment_data[:request_data].blank? and payment_data[:response_data].blank?

    file = Tempfile.new(SecureRandom.hex(8))

    keys_data = {
        merchant_public_key: @merchant_public_key,
        merchant_private_key: @merchant_private_key,
        yeepay_public_key: @yeepay_public_key
      }
    crypto_data = payment_data.merge(keys_data)

    crypto_str = crypto_data.to_json.gsub(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    # crypto_str = JSON.generate(crypto_data, :ascii_only => false)
    file.write(crypto_str)

    file.close
    file.path
  end

  def encypt_data(params)
    _merchantaccount = params[:merchantaccount]

    crypto_data_file_name = store_crypto_data_to_file(payment_data = {request_data: params, merchantaccount: _merchantaccount})

    result = JSON.parse IO.popen("python #{@py_crypto_path} #{crypto_data_file_name}").gets rescue {error: "unknown data", raw_data: result}

    result
  end

  def decypt_data(response_data)
    #_merchantaccount = params[:merchantaccount]
    crypto_data_file_name = store_crypto_data_to_file(payment_data = {response_data: response_data})

    decypt_return = IO.popen("python #{@py_crypto_path} #{crypto_data_file_name}").gets
    result = JSON.parse decypt_return rescue {error: "unknown data", raw_data: decypt_return}

    HashWithIndifferentAccess.new(result)
  end

  def try_decypt_data(response_content)
    response_data = JSON.parse(response_content) rescue {}
    response_data = HashWithIndifferentAccess.new(response_data)

    response_result = if response_data[:data].present?
                        decypt_data(response_data)
                      else
                        response_data
                      end
    response_result
  end

  def launch_request(uri, params)
    encypted_result = encypt_data(params)

    res = Net::HTTP.post_form(uri, encypted_result)

    try_decypt_data(res.body)
  end

  def yeepay_uri(path = nil)
    url = yeepay_host # "http://ok.yeepay.com/"
    uri = URI.parse(url)
    uri.path = path if path.present?
    uri
  end

  class << self

    def generate_order_no
      now = Time.now
      [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
    end

    def merchant_private_key(key_str = nil)
      key_str ||= %q(MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAPGE6DHyrUUAgqep/oGqMIsrJddJNFI1J/BL01zoTZ9+YiluJ7I3uYHtepApj+Jyc4Hfi+08CMSZBTHi5zWHlHQCl0WbdEkSxaiRX9t4aMS13WLYShKBjAZJdoLfYTGlyaw+tm7WG/MR+VWakkPX0pxfG+duZAQeIDoBLVfL++ihAgMBAAECgYAw2urBV862+5BybA/AmPWy4SqJbxR3YKtQj3YVACTbk4w1x0OeaGlNIAW/7bheXTqCVf8PISrA4hdL7RNKH7/mhxoX3sDuCO5nsI4Dj5xF24CymFaSRmvbiKU0Ylso2xAWDZqEs4Le/eDZKSy4LfXA17mxHpMBkzQffDMtiAGBpQJBAPn3mcAwZwzS4wjXldJ+Zoa5pwu1ZRH9fGNYkvhMTp9I9cf3wqJUN+fVPC6TIgLWyDf88XgFfjilNKNz0c/aGGcCQQD3WRxwots1lDcUhS4dpOYYnN3moKNgB07Hkpxkm+bw7xvjjHqI8q/4Jiou16eQURG+hlBZlZz37Y7P+PHF2XG3AkAyng/1WhfUAfRVewpsuIncaEXKWi4gSXthxrLkMteM68JRfvtb0cAMYyKvr72oY4Phyoe/LSWVJOcW3kIzW8+rAkBWekhQNRARBnXPbdS2to1f85A9btJP454udlrJbhxrBh4pC1dYBAlz59v9rpY+Ban/g7QZ7g4IPH0exzm4Y5K3AkBjEVxIKzb2sPDe34Aa6Qd/p6YpG9G6ND0afY+m5phBhH+rNkfYFkr98cBqjDm6NFhT7+CmRrF903gDQZmxCspY)

      unless key_str.start_with?("-----BEGIN")
        key_str = key_str.strip.split(//).each_slice(64).map{|str_slice| str_slice.join}.join("\n")

        key_str = %Q(-----BEGIN RSA PRIVATE KEY-----
#{key_str}
-----END RSA PRIVATE KEY-----)
      end

    end

    def merchant_public_key(key_str = nil)
      key_str ||= %q(MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDxhOgx8q1FAIKnqf6BqjCLKyXXSTRSNSfwS9Nc6E2ffmIpbieyN7mB7XqQKY/icnOB34vtPAjEmQUx4uc1h5R0ApdFm3RJEsWokV/beGjEtd1i2EoSgYwGSXaC32ExpcmsPrZu1hvzEflVmpJD19KcXxvnbmQEHiA6AS1Xy/vooQIDAQAB)

      unless key_str.start_with?("-----BEGIN")
        key_str = key_str.strip.split(//).each_slice(64).map{|str_slice| str_slice.join}.join("\n")

        key_str = %Q(-----BEGIN PUBLIC KEY-----
#{key_str}
-----END PUBLIC KEY-----)
      end

    end

    def yeepay_public_key(key_str = nil)
      key_str ||= %q(MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxnYJL7fH7DVsS920LOqCu8ZzebCc78MMGImzW8MaP/cmBGd57Cw7aRTmdJxFD6jj6lrSfprXIcT7ZXoGL5EYxWUTQGRsl4HZsr1AlaOKxT5UnsuEhA/K1dN1eA4lBpNCRHf9+XDlmqVBUguhNzy6nfNjb2aGE+hkxPP99I1iMlQIDAQAB)

      unless key_str.start_with?("-----BEGIN")
        key_str = key_str.strip.split(//).each_slice(64).map{|str_slice| str_slice.join}.join("\n")

        key_str = %Q(-----BEGIN PUBLIC KEY-----
#{key_str}
-----END PUBLIC KEY-----)
      end

    end
  end
end
