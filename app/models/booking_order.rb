class BookingOrder < ActiveRecord::Base
  belongs_to :booking
  belongs_to :booking_item
  belongs_to :user

  acts_as_enum :status, :in => [
    ['pending', 1, '待处理'],
    ['completed', 2, '已完成'],
    ['canceled', 3, '已取消'],
  ]

  scope :latest, -> { order('created_at DESC') }

  before_create :add_default_attrs, :generate_order_no
  after_create :send_message

  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end

  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  # private

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
    return if tel.blank?

    options = { operation_id: 3, account_id: booking.site.account_id, userable_id: user_id, userable_type: 'User' }
    sms_options = { mobiles: tel, template_code: 'SMS_7260929', params: { name: username, tel: tel, total_amount: total_amount, address: address, remark: description } }

    booking.site.account.send_message(sms_options, false, options)
  end

end
