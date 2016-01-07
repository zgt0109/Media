# == Schema Information
#
# Table name: hotel_room_settings
#
#  id                 :integer          not null, primary key
#  hotel_id           :integer          not null
#  hotel_branch_id    :integer          not null
#  hotel_room_type_id :integer          not null
#  date               :date             not null
#  open_qty           :integer          default(0), not null
#  booked_qty         :integer          default(0), not null
#  available_qty      :integer          default(0), not null
#  status             :integer          default(1), not null
#  description        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class HotelRoomSetting < ActiveRecord::Base
  validates :hotel_branch_id, :hotel_room_type_id, :date, presence: true
  validates_numericality_of  :open_qty, greater_than_or_equal_to: 0, presence: true, only_integer: true

  belongs_to :hotel_branch
  belongs_to :hotel_room_type

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

	def delete!
		update_attributes(status: DELETED) if normal?
	end

end
