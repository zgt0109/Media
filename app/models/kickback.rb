class Kickback < ActiveRecord::Base
  belongs_to :wx_user
  has_many :kickback_items

  before_create :generate_order_no
  # url = "#{YonganPolicyOrder::WXPAY_URL}/wxpay/yaic_pay?#{URI.encode_www_form(order_id: @order.order_no,showwxpaytitle: 1,supplier_id: @supplier.id)}"#wxpay_pay_url( order_id: @order.order_no,showwxpaytitle: 1)

  enum_attr :status, :in => [
    ['unpay', 1, '未支付'],
    ['payed', 2, '已支付']
  ]

  def total_price
    number * 2
    # number * 0.01
  end

  def is_finished?
    # ret = true
    self.kickback_items.each do |ki|
      if !ki.finished? #有任何一个item是没完成的
        return false
      end
    end #每个都是完成的
    return true
  end

  def author_name
    self.wx_user.nickname ||= "匿名"
  end

  def generate_order_no
    now = Time.now
    self.order_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
    if self.word.blank?
      self.word = "助你做雷锋，让你扶人无忧！"
    end
  end

  # attr_accessible :name, :number
end
