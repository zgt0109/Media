# == Schema Information
#
# Table name: car_sellers
#
#  id               :integer          not null, primary key
#  supplier_id      :integer          not null
#  wx_mp_user_id    :integer          not null
#  car_shop_id      :integer          not null
#  seller_type      :integer          default(1), not null
#  name             :string(255)      not null
#  phone            :string(255)      not null
#  position         :string(255)      not null
#  skilled_language :string(255)      not null
#  pic              :string(255)      not null
#  status           :integer          default(1), not null
#  description      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CarSeller < ActiveRecord::Base

	validates :name, :phone, :position, :skilled_language, presence: true
	# validates :pic, presence: true, on: :create

  enum_attr :status, :in => [['normal', 1, '正常'],['deleted', -1, '已删除']]

  enum_attr :seller_type, :in => [
    ['sales_rep', 1, '销售代表'],
    ['sales_consultant', 2, '销售顾问'],
  ]

	belongs_to :car_shop
  belongs_to :wx_mp_user

	def delete!
		update_attributes(status: DELETED) if normal?
	end

  def pic_url(type = :large)
    qiniu_image_url(pic_key)
  end

end
