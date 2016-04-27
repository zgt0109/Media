class BookingOrder < ActiveRecord::Base
  belongs_to :booking
  belongs_to :booking_item
  belongs_to :user
  belongs_to :payment_type

  has_many   :payments, as: :paymentable

  acts_as_enum :status, :in => [
    ['pending',   0, '待支付'],
    ['paid',      1, '已支付'],
    ['completed', 2, '已完成'],
    ['canceled',  -1, '已取消'],
    ['expired',   -2, '已过期']
  ]

  enum_attr :payment_type_id, in: PaymentType::ENUM_ID_OPTIONS

  scope :latest, -> { order('created_at DESC') }

  before_create :add_default_attrs, :generate_order_no
  after_create :update_user_address, :send_message

  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end

  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  def payment_request_params(params = {})
    params = HashWithIndifferentAccess.new(params)

    _order_params = {
      payment_type_id: payment_type_id,
      account_id: booking.site.account_id,
      site_id: booking.site.id,
      customer_id: user_id,
      customer_type: 'User',
      paymentable_id: id,
      paymentable_type: 'BookingOrder',
      out_trade_no: order_no,
      amount: total_amount,
      body: "订单 #{order_no}",
      subject: "订单 #{order_no}",
      source: 'booking_order'
    }

    params.reverse_merge(_order_params)
  end

  private

  def add_default_attrs
    if booking_item
      self.booking_id = booking_item.booking_id
      self.price = booking_item.price
      self.total_amount = self.price * self.qty
    else
      self.price = 0
      self.total_amount = 0
    end
  end

  def generate_order_no
    self.order_no = Concerns::OrderNoGenerator.generate
  end

  def send_message
    return if booking.notify_merchant_mobiles.blank?

    options = { operation_id: 7, site_id: booking.site_id, userable_id: user_id, userable_type: 'User' }
    sms_options = { mobiles: booking.notify_merchant_mobiles, template_code: 'SMS_7260929', params: { name: [booking_item.try(:name), username].compact.join(', '), tel: tel, total_amount: total_amount, address: address, remark: description } }

    booking.site.send_message(sms_options, options)
  end

  def update_user_address
    if self.user
      self.user.name = self.username unless self.user.name
      self.user.address = self.address# unless self.user.address
      self.user.mobile = self.tel unless self.user.mobile
      self.user.save
    end
  end

end
