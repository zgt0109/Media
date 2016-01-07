# == Schema Information
#
# Table name: hotel_orders
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer          not null
#  wx_mp_user_id      :integer          not null
#  wx_user_id         :integer          not null
#  hotel_id           :integer          not null
#  hotel_branch_id    :integer          not null
#  hotel_room_type_id :integer          not null
#  order_no           :string(255)      not null
#  expired_at         :datetime         not null
#  name               :string(255)      not null
#  mobile             :string(255)      not null
#  qty                :integer          default(0), not null
#  check_in_date      :date             not null
#  check_out_date     :date             not null
#  check_in_days      :integer          default(1), not null
#  price              :decimal(12, 2)   default(0.0), not null
#  total_amount       :integer          not null
#  status             :integer          default(1), not null
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class HotelOrder < ActiveRecord::Base
  #attr_accessible :description, :expired_at, :hotel_branch_id, :hotel_id, :order_no, :status, :supplier_id, :total_amount, :wx_mp_user_id, :wx_user_id
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
    if expired?
      '已过期'
    else
      status_name
    end
  end

  def add_default_attrs
    now = Time.now
    self.order_no = [now.strftime('%Y%m%d'), now.usec.to_s.ljust(6, '0')].join

    self.expired_at = "#{self.check_in_date} #{self.hotel.obligate_time}"
    self.price = hotel_room_type.room_price
    self.total_amount = (self.price * self.qty * ((self.check_out_date - self.check_in_date).to_i))
  end
end
