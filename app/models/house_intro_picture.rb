class HouseIntroPicture < ActiveRecord::Base
  belongs_to :house_intro

  validates_presence_of :pic_key

  def pic_url
    pic_key.present? ? qiniu_image_url(pic_key) : ""
  end
end
