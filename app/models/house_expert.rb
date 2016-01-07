# == Schema Information
#
# Table name: house_experts
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  house_id      :integer          not null
#  name          :string(255)      not null
#  intro         :string(255)      not null
#  pic           :string(255)      not null
#  status        :integer          default(1), not null
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class HouseExpert < ActiveRecord::Base
  mount_uploader :pic, HouseExpertUploader

	validates :name, :intro, presence: true, length: { maximum: 50 }
	validates :pic, presence: true

  enum_attr :status, :in => [['normal', 1, '正常'],['deleted', -1, '已删除']]

	belongs_to :house
	has_many :house_expert_comments, dependent: :destroy

  def pic_url
    qiniu_image_url("pic/#{pic}") if pic.present?
  end

	def delete!
		update_attributes(status: DELETED) if normal?
	end
end
