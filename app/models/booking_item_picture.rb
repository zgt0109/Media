class BookingItemPicture < ActiveRecord::Base
  belongs_to :booking_ite

  def pic_url
    qiniu_image_url(pic_key)
  end
end