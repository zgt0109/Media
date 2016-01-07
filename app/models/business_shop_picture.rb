class BusinessShopPicture < ActiveRecord::Base
  mount_uploader :pic, BusinessShopPictureUploader
  img_is_exist({pic: :pic_key})
  belongs_to :business_shop

  scope :recent, -> { order('id DESC') }

  def as_json
    { url: pic.to_s, caption: '' }.to_json
  end
end
