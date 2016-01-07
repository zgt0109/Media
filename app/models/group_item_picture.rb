class GroupItemPicture < ActiveRecord::Base
  mount_uploader :pic, ItemPictureUploader

  belongs_to :group_item

  img_is_exist({pic: :pic_key})

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      super
    end
  end
end
