class HotelComment < ActiveRecord::Base

  belongs_to :hotel
  belongs_to :hotel_branch

  enum_attr :status, :in => [['replying', 0, '未回复'],['replyed', 1, '已回复'],['deleted', -1, '已删除'],]
end
