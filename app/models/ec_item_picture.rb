class EcItemPicture < ActiveRecord::Base
  mount_uploader :pic, ItemPictureUploader

  belongs_to :ec_item
end
