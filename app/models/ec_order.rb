class EcOrder < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :ec_shop

  has_many :payments, as: :paymentable

  has_many :order_items, class_name: 'EcOrderItem'

  enum_attr :status, :in => [
    ['pending',  0,  '待支付'],
    ['paid',     1,  '已付款'],
    ['canceled', 2,  '已取消'],
    ['expired',  3,  '已过期']
  ]

  before_create :add_default_attrs, :generate_order_no

  scope :latest, -> { order('created_at DESC') }

  def self.setup(params)
    transaction do
      address = WxUserAddress.find(params[:address_id])

      ec_order = EcOrder.create!({
        ec_shop_id: params[:ec_shop_id],
        user_id: params[:user_id],
        username: address.username,
        tel: address.tel,
        address: address.detail_info,
      })

      order_item_attrs = []

      ec_carts = EcCart.find(params[:ec_cart_ids])
      ec_carts.each do |ec_cart|
        order_item_attrs << {
          ec_order_id: ec_order.id,
          ec_item_id: ec_cart.ec_item_id,
          qty: ec_cart.qty,
          price: ec_cart.price,
          total_price: ec_cart.qty * ec_cart.price
        }
      end

      EcOrderItem.create!(order_item_attrs)

      EcCart.where(id: params[:ec_cart_ids]).delete_all

      ec_order.update_attributes!(total_amount: ec_order.order_items.sum(:total_price))

      ec_order

    end
  end

  def deleted!
    update_attributes!(status: CANCELED)
  end

  def payment!
    transaction do
      pending_payment = payments.wait_buyer_pay.first
      if pending_payment
        payment = pending_payment
      else
        payment = Payment.setup({
          payment_type_id: 10006,
          site_id: site_id,
          customer_id: user_id,
          customer_type: 'User',
          paymentable_id: id,
          paymentable_type: 'EcOrder',
          out_trade_no: order_no,
          amount: total_amount,
          subject: "微枚迪电商订单 #{order_no}",
          source: 'ec'
        })
      end

      payment
    end
  end

  def pay!
    update_attributes!(status: PAID)
  end

  def self.get_status
    return [['待支付',0],['已付款',1],['已取消',2],['已过期',3]]
  end

  #rails runner EcOrder.clean_error_data
  def self.clean_error_data
    EcOrder.find_each do |order|
      order.order_items.each do |order_item|
        unless order_item.ec_item.present?
          order_item.destroy
        end
      end
    end

    EcCart.find_each do |cart|
      unless cart.ec_item.present?
        cart.destroy
      end
    end
  end

  private
  def add_default_attrs
    return unless self.ec_shop

    self.site_id = self.ec_shop.site_id
  end

  def generate_order_no
    now = Time.now
    self.order_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
  end
end
