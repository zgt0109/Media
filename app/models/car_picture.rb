class CarPicture < ActiveRecord::Base

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

  def pic_path_url
    qiniu_image_url(qiniu_path_key)
  end

end

