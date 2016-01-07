class TripAd < ActiveRecord::Base
	#status:状态（1 正常， -1已删除）
  mount_uploader :pic, PictureUploader
  img_is_exist({pic: :pic_key})

  belongs_to :trip

  # validates :title, presence: true
  # validates :pic, presence: true, on: :create
  # validates :pic_key, presence: true, on: :create

  def pic_url
    if pic_key.present?
      qiniu_image_url(pic_key)
    else
      super
    end
  end
end
