class BookingItemPicture < ActiveRecord::Base
  belongs_to :booking_item

  def pic_url
    qiniu_image_url(pic_key)
  end
end