class BookingAd < ActiveRecord::Base
  mount_uploader :pic, AdPictureUploader
  img_is_exist({pic: :qiniu_pic_key})

  belongs_to :supplier
  belongs_to :wx_mp_user

  validates :title, presence: true
  validates :pic, presence: true, on: :create
  validates :url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true

  before_create :add_default_attrs

  def add_default_attrs
    return unless supplier
    self.wx_mp_user_id = supplier.wx_mp_user.try(:id)
  end
end