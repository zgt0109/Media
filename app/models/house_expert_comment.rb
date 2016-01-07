# == Schema Information
#
# Table name: house_expert_comments
#
#  id              :integer          not null, primary key
#  house_id        :integer          not null
#  house_expert_id :integer          not null
#  content         :text             default(""), not null
#  status          :integer          default(1), not null
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class HouseExpertComment < ActiveRecord::Base

	validates :content, presence: true, length: { maximum: 200 }
	validates :house_expert_id, presence: true

	belongs_to :house
	belongs_to :house_expert

  enum_attr :status, :in => [['normal', 1, '正常'],['deleted', -1, '已删除']]

 	def delete!
		update_attributes(status: DELETED) if normal?
	end

end
