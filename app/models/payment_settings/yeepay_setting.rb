# yeepay need field in payment_setting
# partner_account => merchantaccount
# pay_sign_key => yeepay_public_key
# pay_private_key => merchant_private_key
# pay_public_key => merchant_public_key
# yeepay_productcatalog => productcatalog
class YeepaySetting < PaymentSetting
  self.inheritance_column = 'type'

  include YeepaySettingable
end
