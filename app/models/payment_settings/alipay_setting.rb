# alipay need field in payment_setting
# partner_id => partner_id
# partner_key => partner_key
# partner_account => seller_email
class AlipaySetting < PaymentSetting
  self.inheritance_column = 'type'
  include AlipaySettingable
end
