# == Schema Information
#
# Table name: car_catenas
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  car_shop_id   :integer          not null
#  car_brand_id  :integer          not null
#  name          :string(255)      not null
#  sort          :integer          default(0), not null
#  status        :integer          default(1)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CarCatena < ActiveRecord::Base
  mount_uploader :pic, CarPictureUploader
  img_is_exist({pic: :qiniu_pic_key}) 
  belongs_to :car_brand
  has_many :car_pictures, dependent: :destroy
  has_many :car_types, dependent: :destroy
  validates :name, :presence => true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def pic_url(type = :large)
    qiniu_image_url(qiniu_pic_key) || pic.try(type)
  end

  def display_name
    name[0..15] rescue ""
  end

	def delete!
		update_attributes(status: DELETED) if normal?
	end

end
