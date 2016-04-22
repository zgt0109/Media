class PaymentSetting < ActiveRecord::Base
  self.inheritance_column = ''

  enum_attr :status, :in => [
    ['enabled', 1, '已启用'],
    ['disabled', -1, '已停用'],
  ]

  enum_attr :payment_type_id, in: PaymentType::ENUM_ID_OPTIONS

  enum_attr :product_catalog, :in => [
    ['product_catalog1', '1', '1 虚拟产品'],
    # ['product_catalog2', '2', '2 信用卡还款'],
    ['product_catalog3', '3', '3 公共事业缴费'],
    ['product_catalog4', '4', '4 手机充值'],
    ['product_catalog5', '5', '5 普通商品'],
    ['product_catalog6', '6', '6 公益事业'],
    ['product_catalog7', '7', '7 实物电商'],
    ['product_catalog8', '8', '8 彩票业务'],
    ['product_catalog9', '9', '9 电信'],
    ['product_catalog10', '10', '10 行政教育'],
    ['product_catalog11', '11', '11 线下服务业'],
    ['product_catalog13', '13', '13 微信实物电商'],
    ['product_catalog14', '14', '14 微信虚拟电商'],
    ['product_catalog15', '15', '15 保险行业'],
    ['product_catalog16', '16', '16 基金行业'],
    ['product_catalog17', '17', '17 电子票务'],
    ['product_catalog18', '18', '18 金融投资'],
    ['product_catalog19', '19', '19 大额支付'],
    ['product_catalog20', '20', '20 其他'],
    ['product_catalog21', '21', '21 旅游机票'],
    ['product_catalog46', '46', '46 交通运输'],
    ['product_catalog47', '47', '47 酒店行业'],
    ['product_catalog48', '48', '48 生活服务'],
    ['product_catalog49', '49', '49 电信运营'],
    ['product_catalog50', '50', '50 充值缴费'],
    ['product_catalog51', '51', '51 医疗行业'],
    ['product_catalog52', '52', '52 彩票行业'],
    ['product_catalog53', '53', '53 网络服务'],
    ['product_catalog57', '57', '57 综合业务'],
    ['product_catalog58', '58', '58 快消连锁'],
    ['product_catalog6400', '6400', '6400 汽车销售'],
  ]

  WEIXIN_NOTICE_URL =  "#{M_HOST}/payment/wxpay/notify"
  WEIXIN_PAY_URL =  "#{M_HOST}/payment/wxpay/pay"

  validates :payment_type_id, :partner_id, :partner_key, presence: true
  validates :partner_account, presence: true, if: :alipay?
  validates :pay_public_key, :pay_private_key, presence: true, if: :yeepay?
  validates :app_id, presence: true, if: :wxpay?
  validates :app_id, :api_client_cert, :api_client_key, presence: true, if: :wx_redpacket_pay?

  belongs_to :site
  belongs_to :payment_type

  # attr_accessible :app_id, :app_secret, :partner_id, :partner_key, :pay_private_key, :pay_public_key, :pay_sign_key

  before_save :update_type
  after_save :update_wx_mp_user_info

  def enable!
    update_attributes(status: ENABLED)
  end

  def disable!
    update_attributes(status: DISABLED)
  end

  def app_signature open_id, payment
    timestamp = Time.now.to_i
    deliver_status = 1
    deliver_msg = 'ok'
    #a = ["appid", "appkey","openid","transid","out_trad_no","deliver_timestamp","deliver_status","deliver_msg"]
    sign = Digest::SHA1.hexdigest "appid=#{self.app_id}&appkey=#{self.pay_sign_key}&deliver_msg=#{deliver_msg}&deliver_status=#{deliver_status}&deliver_timestamp=#{timestamp}&openid=#{open_id}&out_trade_no=#{payment.out_trade_no}&transid=#{payment.trade_no}"
    wx_mp_user = payment.account.site.wx_mp_user
    wx_mp_user.auth!
    request_url = "https://api.weixin.qq.com/pay/delivernotify?access_token=#{wx_mp_user.access_token}"
    json = "{
      \"appid\" : \"#{self.app_id}\",
      \"openid\" : \"#{open_id}\",
      \"transid\" : \"#{payment.trade_no}\",
      \"out_trade_no\" : \"#{payment.out_trade_no}\",
      \"deliver_timestamp\" : \"#{timestamp}\",
      \"deliver_status\" : \"#{deliver_status}\",
      \"deliver_msg\" : \"#{deliver_msg}\",
      \"app_signature\" : \"#{sign}\",
      \"sign_method\" : \"sha1\"

    }"

    result = RestClient.post(request_url, json)
  end

  def update_type
    if self.wxpay?
      self.type = 'WxpaySetting'
    elsif self.alipay?
      self.type = 'AlipaySetting'
    elsif self.tenpay?
      self.type = 'TenpaySetting'
    elsif self.yeepay?
      self.type = 'YeepaySetting'
    elsif self.cashpay?
      self.type = 'CashpaySetting'
    elsif self.wx_redpacket_pay?
      self.type = 'WxredpacketpaySetting'
    end
  end

  def update_wx_mp_user_info
    return unless wxpay?
    return if app_id.blank? || app_secret.blank?

    wx_mp_user = site.try(:wx_mp_user)
    if wx_mp_user# && wx_mp_user.app_id.blank? && wx_mp_user.app_secret.blank?
      wx_mp_user.update_attributes!(app_id: app_id, app_secret: app_secret)
    end
  end

end
