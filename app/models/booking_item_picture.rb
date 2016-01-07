class BookingItemPicture < ActiveRecord::Base
  mount_uploader :pic, ItemPictureUploader
  img_is_exist({pic: :qiniu_pic_key})
  belongs_to :booking_ite

end