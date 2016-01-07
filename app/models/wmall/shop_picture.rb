class Wmall::ShopPicture < ActiveRecord::Base
  belongs_to :shop

  def pic_url
    if pre_pic_url.present?
      pre_pic_url
    elsif pic_key.present?
      qiniu_image_url(pic_key)
    else
      ""
    end
  end
end
