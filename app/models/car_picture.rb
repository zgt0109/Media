# == Schema Information
#
# Table name: car_pictures
#
#  id            :integer          not null, primary key
#  car_shop_id   :integer          not null
#  car_catena_id :integer          not null
#  name          :string(255)
#  path          :string(255)      not null
#  is_cover      :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CarPicture < ActiveRecord::Base
  mount_uploader :path, CarPictureUploader
  img_is_exist({path: :qiniu_path_key}) 

	# validates :car_catena_id, :path, presence: true

  belongs_to :car_catena
  belongs_to :car_shop
  belongs_to :car_type

  enum_attr :pic_type, :in => [
    ['general', 1, '车型图'],
    ['panoramic', 2, '全景图']
  ]

	def cover!
		update_attributes(is_cover: true) unless is_cover
	end

	def discover!
		update_attributes(is_cover: false) if is_cover
	end

  def pic_url(type = :large)
    qiniu_image_url(qiniu_path_key) || path.try(type).try(:url)
  end

  def pic_path(type = :large)
    qiniu_image_url(qiniu_path_key) || "http://#{Settings.hostname}#{path.try(type).try(:url)}"
  end

end

