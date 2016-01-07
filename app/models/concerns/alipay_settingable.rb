module AlipaySettingable
  extend ActiveSupport::Concern

  included do
    alias_attribute :seller_email, :partner_account

    validates :partner_id, :partner_key, :seller_email, presence: true

    attr_accessor :alipay_pay_options

    def alipay_pay_options
      _options = HashWithIndifferentAccess.new({})
      _options[:getway_url] = 'http://wappaygw.alipay.com/service/rest.htm'
      _options[:default_charset] = 'utf-8'
      _options[:sign_type] = 'MD5'
      _options[:attr_required] = [:service, :partner, :_input_charset, :sign_type, :sign, :notify_url, :call_back_url, :out_trade_no, :subject, :payment_type, :seller_email ]
      _options[:service] = "alipay.wap.trade.create.direct"

      @alipay_pay_options ||= HashWithIndifferentAccess.new({})
      @alipay_pay_options.reverse_merge!(_options)
      @alipay_pay_options
    end

    def alipay_url(options = {})
      options = HashWithIndifferentAccess.new(options)
      Rails.logger.info  options.inspect
      request_token = alipay_auth(options)
      alipay_trade(request_token)
    end


    def alipay_auth(options={})
      # 基础参数
      options.merge!(service: alipay_pay_options[:service], format: "xml", v: "2.0", partner: partner_id, req_id: SecureRandom.urlsafe_base64(24), sec_id: "MD5")
      sign = alipay_sign(options)
      options.merge!(sign: sign)
      gateway_api_url = alipay_pay_options[:getway_url] + "?" + URI.encode_www_form(options)

      res = HTTParty.get gateway_api_url
      raw_res_data = URI.decode(Hash[*res.body.split(/=|&/)]["res_data"]) rescue URI.decode(Hash[*res.body.split(/=|&/)]["res_error"])
      res_data = Hash.from_xml raw_res_data

      # PAYMENT_LOGGER.error "alipay alipay_auth failure: #{res_data}" if res_data["err"].present?
      WinwemediaLog::Payment.logger.error "alipay alipay_auth failure: #{res_data}" if res_data["err"].present?
      request_token = res_data["direct_trade_create_res"]["request_token"]
    end

    def alipay_trade(request_token)
      # 业务参数
      options = {req_data: "<auth_and_execute_req><request_token>#{request_token}</request_token></auth_and_execute_req>"}
      # 基础参数
      options.merge!(service: "alipay.wap.auth.authAndExecute", format: "xml", v: "2.0", partner: partner_id, sec_id: "MD5")
      sign = alipay_sign(options)
      options.merge!(sign: sign)
      Rails.logger.info options.inspect
      gateway_api_url = alipay_pay_options[:getway_url] + "?" + URI.encode_www_form(options)
    end

    def alipay_sign(options)
      options = HashWithIndifferentAccess.new(options)
      #Digest::MD5.hexdigest(options.sort.map{|k,v|"#{k}=#{URI.escape(v.to_s)}"}.join("&")+ALIPAY_KEY)
      Digest::MD5.hexdigest(options.sort.map{|k,v|"#{k}=#{v.to_s}"}.join("&")+partner_key)
    end
  end

  module ClassMethods
    def default_params
      PAYMENT_CONFIG[:alipay]
    end
  end
  
end
