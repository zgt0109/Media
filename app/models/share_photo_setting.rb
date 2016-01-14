class SharePhotoSetting < ActiveRecord::Base
  belongs_to :site, inverse_of: :share_photo_setting
  has_many :share_photos
  has_many :activities, as: :activityable
  has_many :share_photos

  validates :request_expired_at, presence: true, numericality: { only_integer: true, greater_than: 0 }
  scope :activity_share_photos, -> { where(activity_type_id: [33,34]) }
  accepts_nested_attributes_for :activities

  def respond_create_share_photo(wx_user, pic_url)
    if wx_user.matched_in_minutes?(request_expired_at)
      share_photos.create(site_id: site_id, user_id: wx_user.user_id, pic_url: pic_url)
      wx_user.share_photos!
      Weixin.respond_text(wx_user.openid, site.wx_mp_user.openid, upload_description)
    else #超时
      wx_user.normal!
      Weixin.respond_text(wx_user.openid, site.wx_mp_user.openid, "您进入晒图模式已超过#{request_expired_at}分钟，系统自动退出晒图模式，输入关键词重新进入")
    end
  rescue e
    Weixin.respond_text(wx_user.openid, site.wx_mp_user.openid, "error001:#{e}")
  end

end
