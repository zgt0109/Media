class CasePicture < ActiveRecord::Base
  belongs_to :case

  def pic_url
    qiniu_image_url(pic)
  end
end
