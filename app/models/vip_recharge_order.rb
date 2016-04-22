class VipRechargeOrder < ActiveRecord::Base

  belongs_to :vip_user
  belongs_to :site

  has_one :payment, as: :paymentable

  #实际支付金额
  #validates :pay_amount, presence: true, numericality: {greater_than: 0}

  #充值金额
  validates :amount, presence: true, numericality: {greater_than: 0}

  before_create :generate_order_no

  enum_attr :status, :in => [
    ['pending',  1,  '待支付'],
    ['paid',     2,  '已付款'],
    ['canceled', 3,  '已取消'],
    ['expired',  4,  '已过期']
  ]

  enum_attr :pay_type, :in => [
    ['wxpay', 10001, '微信'],
    # ['yeepay', 10002, '易宝'],
    ['alipay', 10003, '支付宝'],
    ['tenpay', 10004, '财付通']
  ]

  def wx_user_id
    vip_user.user.wx_user_id
  end

  # just for alipay
  def payment!
    transaction do
      payment ||= Payment.setup({
        payment_type_id: pay_type,
        account_id: site.account_id,
        site_id: site.id,
        customer_id: vip_user_id,
        customer_type: 'VipUser',
        open_id: vip_user.user.wx_user.try(:openid),
        paymentable_id: id,
        paymentable_type: 'VipRechargeOrder',
        out_trade_no: order_no,
        amount: pay_amount,
        subject: "会员卡#{pay_type_name}充值 #{order_no} #{amount}",
        source: 'vip_recharge'
      })
    end
    payment
  end

  def payment_request_params(params = {})
    params = HashWithIndifferentAccess.new(params)
    _order_params = {
      payment_type_id: pay_type,
      account_id: site.account_id,
      site_id: site_id,
      customer_id: vip_user_id,
      customer_type: 'VipUser',
      open_id: vip_user.user.wx_user.try(:openid),
      paymentable_id: id,
      paymentable_type: 'VipRechargeOrder',
      out_trade_no: order_no,
      amount: pay_amount,
      body:  "会员卡#{pay_type_name}充值 #{order_no} #{amount}",
      subject:  "会员卡#{pay_type_name}充值",
      source: 'vip_recharge'
    }
    params.reverse_merge(_order_params)
  end

  def pay!
    update_attributes!(status: PAID)
  end

  def recharge!
    if pending?
      vip_user.increase_amount!(amount, '充值', {payment_type: pay_type.to_s, direction: '3', description: "#{pay_type_name}充值", amount_source: VipUserTransaction::WEB_PAY_UP})
      pay!
    end
  end

  private
    def generate_order_no
      self.order_no = Concerns::OrderNoGenerator.generate
    end
end
