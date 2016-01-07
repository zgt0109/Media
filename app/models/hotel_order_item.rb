# == Schema Information
#
# Table name: hotel_order_items
#
#  id                 :integer          not null, primary key
#  supplier_id        :integer          not null
#  wx_mp_user_id      :integer          not null
#  wx_user_id         :integer          not null
#  hotel_id           :integer          not null
#  hotel_branch_id    :integer          not null
#  hotel_room_type_id :integer          not null
#  hotel_order_id     :integer          not null
#  check_in_date      :date             not null
#  status             :integer          default(1), not null
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class HotelOrderItem < ActiveRecord::Base
  attr_accessible :check_in, :check_in, :hotel_branch_id, :hotel_id, :hotel_order_item_id, :hotel_room_id, :mobile, :name, :price, :qty, :supplier_id, :total_price, :wx_mp_user_id
end
