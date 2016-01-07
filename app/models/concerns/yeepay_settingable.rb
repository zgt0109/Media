module YeepaySettingable
  extend ActiveSupport::Concern

  included do
    alias_attribute :merchantaccount, :partner_id
    alias_attribute :yeepay_public_key, :partner_key
    alias_attribute :merchant_private_key, :pay_private_key
    alias_attribute :merchant_public_key, :pay_public_key
    alias_attribute :productcatalog, :product_catalog

    validates :partner_account, :pay_sign_key, :pay_private_key,
                 :pay_public_key, :productcatalog, presence: true
  end

  def customer_option
    yeepay_setting = self

    yeepay_setting_option = HashWithIndifferentAccess.new({
      merchantaccount: yeepay_setting.merchantaccount,
      yeepay_public_key: yeepay_setting.yeepay_public_key,
      merchant_private_key: yeepay_setting.merchant_private_key,
      merchant_public_key: yeepay_setting.merchant_public_key
    })

    self.class.default_options(yeepay_setting_option)
  end

  def customer_default_params
    _default_params = PAYMENT_CONFIG[:yeepay].slice(:yeepay_host, :callbackurl, :fcallbackurl)
    _default_params[:callbackurl] = _default_params[:callbackurl] % {merchantaccount: merchantaccount}
    _default_params[:fcallbackurl] = _default_params[:fcallbackurl] % {merchantaccount: merchantaccount}

    _default_params
  end

  def crypto
    YeepayLib::Crypto.new(customer_option, customer_default_params)
  end

  module ClassMethods
    def default_params
      PAYMENT_CONFIG[:yeepay]
    end

    def api_path(name)
      PAYMENT_CONFIG[:yeepay_api_path][name] % {api_env: "paymobile"}
    end

    def default_options(params = nil)
      params ||= {}
      params.reverse_merge!(default_params.slice(:yeepay_host)) if default_params.has_key?(:yeepay_host)
      HashWithIndifferentAccess.new(params)
    end
  end
end
