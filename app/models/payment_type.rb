class PaymentType < ActiveRecord::Base

  enum_attr :status, :in => [
    ['enabled', 1, '启用'],
    ['disabled', -1, '停用'],
  ]

  ENUM_ID_OPTIONS = [
    ['wxpay', 10001, '微信支付V2'],
    ['tenpay', 10002, '财付通'],
    ['yeepay', 10003, '易宝'],
    ['weixinpay', 10004, '微信支付V3'],
    ['cashpay', 10005, '现金支付'],
    ['alipay', 10006, '支付宝'],
    ['vip_userpay', 10007, '余额支付'],
    ['wx_redpacket_pay', 10008, '微信红包'],
    ['proxy_alipay', 20001, '微枚迪支付宝'],
    ['proxy_yeepay', 20002, '微枚迪易宝'],
  ]

  enum_attr :id, in: ENUM_ID_OPTIONS

end
