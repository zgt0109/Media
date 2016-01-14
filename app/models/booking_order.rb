class BookingOrder < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :booking_item

  acts_as_enum :status, :in => [
    ['pending', 1, '待处理'],
    ['completed', 2, '已完成'],
    ['canceled', 3, '已取消'],
  ]

  scope :latest, -> { order('created_at DESC') }

  before_create :add_default_attrs, :generate_order_no
  
  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end
  
  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  private

  def add_default_attrs
    if booking_item
      self.site_id = booking_item.site_id
      self.price = booking_item.price
      self.total_amount = self.price * self.qty
    else
      self.price = 0
      self.total_amount = 0
    end
  end

  def generate_order_no
    now = Time.now
    self.order_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
  end

end
