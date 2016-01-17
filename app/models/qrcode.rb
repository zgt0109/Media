class Qrcode < ActiveRecord::Base
  validates :scene_id, uniqueness: {scope: :site_id}

  belongs_to :site
  has_many :qrcode_logs
  has_many :qrcode_users
  has_one :qrcode_channel

  enum_attr :action_name, :in => [
    ['qr_scene', 1, '临时 '],
    ['qr_limit_scene', 2, '永久'],
  ]

  def create_or_normalize_log(wx_user, xml)
    qrcode_log = qrcode_logs.where(user_id: wx_user.user_id).earliest.first
    qrcode_users.where(site_id: site_id, user_id: wx_user.user_id).first_or_create
    return if wx_user.qrcode_logs.normal.exists?

    if qrcode_log
      qrcode_log.normal! if qrcode_log.deleted?
    else
      qrcode_logs.create(site_id: site_id, user_id: wx_user.user_id, qrcodeable: qrcode_channel, event: xml[:Event], event_key: xml[:EventKey])
    end
  end
end
