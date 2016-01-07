# == Schema Information
#
# Table name: house_comments
#
#  id            :integer          not null, primary key
#  house_id      :integer          not null
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  wx_user_id    :integer          not null
#  name          :string(255)      not null
#  mobile        :string(255)      not null
#  content       :text             default(""), not null
#  reply_content :text
#  status        :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class HouseComment < ActiveRecord::Base

	validates :reply_content, presence: true, length: { maximum: 200 }, on: :update
#  validates :name, presence: true, length: { maximum: 16 }
#  validates :mobile, format: { with: /^1[3|4|5|8][0-9]\d{8}$/i, on: :create }
#  validates :content, presence: true, length: { maximum: 300 }


  enum_attr :status, :in => [['replying', 0, '未回复'],['replyed', 1, '已回复'],['deleted', -1, '已删除'],]

#	before_update :add_default_attrs
	
#	def add_default_attrs
		
#	end
end
