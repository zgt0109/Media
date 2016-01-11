class TripAd < ActiveRecord::Base
  belongs_to :trip

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      super
    end
  end
end
