class VipRechargeOrder < ActiveRecord::Base

  belongs_to :vip_user

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
    ['alipay',  1,  '支付宝'],
    ['wxpayv2', 2,  '微信'],
    ['wxpayv3', 4,  '微信'],
    ['tenpay',  3,  '财付通']
  ]

  def wx_user_id
    vip_user.user.wx_user_id
  end

  def payment!
    transaction do
      payment ||= Payment.setup({
        payment_type_id: 10006,
        account_id: account_id,
        customer_id: vip_user_id,
        customer_type: 'VipUser',
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
      payment_type_id: wxpayv2? ? 10001 : 10004,
      account_id: account_id,
      customer_id: user_id,
      customer_type: 'User',
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
      vip_user.increase_amount!(amount, '充值', {payment_type: (pay_type+2).to_s, direction: '3', description: "#{pay_type_name}充值", amount_source: VipUserTransaction::WEB_PAY_UP})
      pay!
    end
  end

  private
    def generate_order_no
      self.order_no = Concerns::OrderNoGenerator.generate
    end
end
