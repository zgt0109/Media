class HotelOrder < ActiveRecord::Base
  before_create :add_default_attrs

  belongs_to :hotel
  belongs_to :hotel_branch
  belongs_to :hotel_room_type

  enum_attr :status, :in => [
    ['incomplete', 1, '未完成'],
    ['completed', 2, '已完成'],
    ['expired', -1, '已过期'],
    ['revoked', -2, '已撤消'],
  ]

  def revoked!
    HotelOrder.transaction do
      update_attributes!(status: REVOKED)

      hotel_room_type.hotel_room_settings.normal.where('date between ? and ?', check_in_date, check_out_date-1.days).each do |room_setting|
        room_setting.update_attributes!(booked_qty: room_setting.booked_qty-qty, available_qty: room_setting.available_qty + qty)
      end
    end
    true
  rescue => error
    false
  end

  def completed!
    update_attributes(status: COMPLETED)
  end

  def expired?
    # - 1.hours
    update_attributes(status: EXPIRED) if (( created_at < expired_at and Time.now > expired_at ) or ( created_at >= expired_at and Date.today > expired_at.to_date )) and incomplete?
  end

  def real_status_name
    expired? ? '已过期' : status_name
  end

  def add_default_attrs
    self.order_no = Concerns::OrderNoGenerator.generate
    self.expired_at = "#{self.check_in_date} #{self.hotel.obligate_time}"
    self.price = hotel_room_type.room_price
    self.total_amount = (self.price * self.qty * ((self.check_out_date - self.check_in_date).to_i))
  end
end
