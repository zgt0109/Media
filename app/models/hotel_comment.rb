# == Schema Information
#
# Table name: hotel_comments
#
#  id              :integer          not null, primary key
#  hotel_id        :integer          not null
#  hotel_branch_id :integer          not null
#  supplier_id     :integer          not null
#  wx_mp_user_id   :integer          not null
#  wx_user_id      :integer          not null
#  hotel_order_id  :integer
#  name            :string(255)      not null
#  mobile          :string(255)      not null
#  content         :text             default(""), not null
#  reply_content   :text
#  status          :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class HotelComment < ActiveRecord::Base
  #attr_accessible :content, :hotel_id, :mobile, :name, :reply_content, :status, :supplier_id, :wx_mp_user_id, :wx_user_id
  
  belongs_to :hotel
  belongs_to :hotel_branch
  
  enum_attr :status, :in => [['replying', 0, '未回复'],['replyed', 1, '已回复'],['deleted', -1, '已删除'],]
end
