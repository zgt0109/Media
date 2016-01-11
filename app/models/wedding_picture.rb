class WeddingPicture < ActiveRecord::Base
  belongs_to :wedding

  scope :cover, -> { where(is_cover: true) }

  def pic_url
    pic_key.present? ? qiniu_image_url(pic_key) : ""
  end
end
