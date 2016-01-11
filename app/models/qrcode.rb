class Qrcode < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :scene_id, uniqueness: {scope: :wx_mp_user_id}



  belongs_to :site
  belongs_to :wx_mp_user
  has_many :qrcode_logs
  has_many :qrcode_users
  has_one :channel_qrcode

  enum_attr :action_name, :in => [
      ['qr_scene', 1, '临时 '],
      ['qr_limit_scene', 2, '永久'],
  ]

  def create_or_normalize_log(wx_user, xml)
    qrcode_log = qrcode_logs.where(wx_user_id: wx_user.id).earliest.first
    qrcode_users.where(supplier_id: supplier_id, wx_user_id: wx_user.id).first_or_create
    return if wx_user.qrcode_logs.normal.exists?

    if qrcode_log
      qrcode_log.normal! if qrcode_log.deleted?
    else
      qrcode_logs.create(supplier_id: supplier_id, wx_mp_user_id: wx_mp_user_id, wx_user_id: wx_user.id, qrcodeable: channel_qrcode, event: xml[:Event], event_key: xml[:EventKey])
    end
  end
end
