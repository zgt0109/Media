class PaymentType < ActiveRecord::Base

  enum_attr :status, :in => [
    ['enabled', 1, '启用'],
    ['disabled', -1, '停用'],
  ]

  ENUM_ID_OPTIONS = [
    ['cashpay', 10000, '现金支付'],
    ['wxpay', 10001, '微信支付'],
    ['yeepay', 10002, '易宝支付'],
    ['alipay', 10003, '支付宝支付'],
    ['tenpay', 10004, '财付通支付'],
    ['vip_userpay', 10005, '余额支付'],
    ['wx_redpacket_pay', 10006, '微信红包'],
    ['proxy_alipay', 20001, '微枚迪支付宝'],
    ['proxy_yeepay', 20002, '微枚迪易宝'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS

end
