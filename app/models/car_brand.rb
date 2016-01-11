# == Schema Information
#
# Table name: car_brands
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  car_shop_id   :integer          not null
#  name          :string(255)      not null
#  sort          :integer          default(0), not null
#  status        :integer          default(1)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CarBrand < ActiveRecord::Base
	validates :name, presence: true

	has_many :car_types
	has_many :car_catenas
  belongs_to :car_shop
  belongs_to :wx_mp_user

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

	def delete!
		update_attributes(status: DELETED) if normal?
	end

	def logo_url(type = :large)
		qiniu_image_url(logo_key) || logo.try(type)
	end

end
