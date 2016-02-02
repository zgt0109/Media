require 'uri'

class WxMpUser < ActiveRecord::Base
  include Concerns::WxMpUserPlugin

  validates :account_id, :site_id, :status, :nickname, presence: true
  # validates :nickname, presence: true, uniqueness: { case_sensitive: false }
  # validates :openid, presence: true, on: :create

  serialize :func_info, JSON

  enum_attr :status, :in => [
    ['pending', 0, '待激活'],
    ['active', 1, '已开启'],
    ['disabled', 2, '已过期，待激活'],
    ['froze', -1, '已冻结']
  ]

  enum_attr :user_type, :in => [
    ['default_user', 0, '未识别类型'],
    ['subscribe', 1, '订阅号'],
    ['auth_subscribe', 2, '认证订阅号'],
    ['service', 3, '服务号'],
    ['auth_service', 4, '认证服务号'],
  ]

  enum_attr :bind_type, :in => [
    ['cancel', -1, '取消'],
    ['manual', 1, '默认'],
    ['plugin', 2, '插件'],
  ]

  belongs_to :site, inverse_of: :wx_mp_user

  has_many :replies, as: :replier, dependent: :destroy

  has_many :stat_wx_users ,:foreign_key => "openid",:primary_key => "openid"

  has_many :stat_wx_articles ,:foreign_key => "openid" ,:primary_key => "openid"
  has_many :stat_wx_hour_articles ,:foreign_key => "openid" ,:primary_key => "openid"
  has_many :stat_wx_msgs ,:foreign_key => "openid" ,:primary_key => "openid"
  has_many :stat_wx_hour_msgs ,:foreign_key => "openid" ,:primary_key => "openid"

  has_many :wx_users, inverse_of: :wx_mp_user
  has_many :users, through: :wx_users
  has_many :vip_users, through: :users
  has_many :wx_menus
  has_many :cards, class_name: "Wx::Card"

  before_create { generate_token(:token) }
  before_create :generate_code
  before_save :format_data
  after_create :generate_url

  class << self
    def generate_key
      'win'+SecureRandom.hex(20)
    end

    def find_by_code_or_app_id(code, app_id)
      case
        when code.present?   then find_and_update_description(:code, code, 1)
        when app_id.present? then find_and_update_description(:app_id, app_id, 2)
      end
    end

    def find_and_update_description(field, value, bind_type)
      mp_user = WxMpUser.where(field => value).first
      return unless mp_user

      mp_user.attributes = { bind_type: bind_type }
      mp_user.save if mp_user.changed?
      mp_user
    end
  end

  def first_follow_reply
    replies.click_event.first rescue nil
  end

  def autoreply
    replies.text_event.first rescue nil
  end

  def kf_account
    Kf::Account.where(token: kefu_token).first
  end

  def can_fetch_wx_user_info?
    auth_subscribe? || auth_service?
  end

  def qrcode_url
    qrcode_key.present? ? qiniu_image_url(qrcode_key) : self['qrcode_url']
  end

  def has_fans?(wx_user_id = nil)
    conditions = wx_user_id.to_i > 0 ? {id: wx_user_id} : {}
    wx_users.where(conditions).first
  end

  def update_openid_to(new_openid = nil)
    # if openid.present? && openid != openid
    #   WxMpUser.where(openid: openid).where('id != ?', id).update_all(openid: "#{openid}_#{Time.now.to_i}", app_id: "#{app_id}_#{Time.now.to_i}")
    #   update_attributes(openid: openid)
    # end
    update_attributes(openid: new_openid) if openid.blank?
  end

  def authorized_auth_subscribe?
    auth_service? && is_oauth?
  end

  def kefu_enter_command
    self.kefu_enter.blank? ? '00' : self.kefu_enter
  end

  def kefu_quit_command
    self.kefu_quit.blank? ? '退出' : self.kefu_quit
  end

  def active!
    b_count = binds_count
    b_count += 1 if pending?
    update_attributes(status: ACTIVE, binds_count: b_count)
  end

  def open_oauth!
    update_attributes(is_oauth: true)
  end

  def close_oauth!
    update_attributes(is_oauth: false)
  end

  def upgraded_text
    active? ? '升级成功' : ''
  end

  def get_wx_jsapi_ticket!
    return true if !wx_jsapi_auth_expired?
    return false if wx_access_token.blank?

    result = RestClient.get(URI::encode("https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{wx_access_token}&type=jsapi"))

    data = JSON(result)

    if data['errcode'].to_i == 0
      update_attributes(wx_jsapi_ticket: data['ticket'], wx_jsapi_expires_in: 1.5.hours.from_now) if data['ticket'].present?
    end

  rescue => error
    WinwemediaLog::Base.logger('wxjsapi', "****** [Ticket] wx_mp_user #{id} get ticket error: #{error.message}")
    return false
  end

  def get_wx_jsapi_ticket
    get_wx_jsapi_ticket! if wx_jsapi_auth_expired?
    wx_jsapi_ticket
  end

  def wx_jsapi_auth_expired?
    return true if wx_jsapi_expires_in.blank?
    Time.now >= wx_jsapi_expires_in
  end

  def auth_expired?
    return true if expires_in.blank?

    Time.now >= expires_in
  end

  def auth!(force_auth = false)
    return true if !force_auth && !auth_expired?

    if manual?
      return false if app_id.blank? || app_secret.blank?
      result = RestClient.get(URI::encode("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{app_id}&secret=#{app_secret}"))
      data = JSON(result)
      # WinwemediaLog::Base.logger('wxapi', "****** [Token] wx_mp_user #{id} get token response: #{data}")
      return update_attributes(access_token: data['access_token'], expires_in: 1.8.hours.from_now) if data['access_token'].present?
    else
      refresh_access_token!
    end
  rescue => error
    WinwemediaLog::Base.logger('wxapi', "****** [Token] wx_mp_user #{id} get token error: #{error.message}")
    return false
  end

  def wx_access_token
    auth!(true) if auth_expired?
    access_token
  end





  def enable!
    return false if wx_menus.root.count == 0 || !auth!

    menu_text = JSON.generate({button: wx_menus.root.order(:sort).map(&:wx_api_json)})
    # WinwemediaLog::Base.logger('wxapi', "****** [Menu] wx_mp_user #{id} create menu access_token: #{access_token} data:#{menu_text}")

    result = RestClient.post(URI::encode("https://api.weixin.qq.com/cgi-bin/menu/create?access_token=#{access_token}"), menu_text)
    data = JSON(result)
    # WinwemediaLog::Base.logger('wxapi', "****** [Menu] wx_mp_user #{id} create menu response: #{data}")

    if data['errcode'].to_i == 0
      update_attributes(is_sync: true)
    else
      return false
    end
  rescue => error
    WinwemediaLog::Base.logger('wxapi', "****** [Menu] wx_mp_user #{id} create menu error: #{error.message}")
    return false
  end

  def disable!
    return false unless auth!

    result = RestClient.get(URI::encode("https://api.weixin.qq.com/cgi-bin/menu/delete?access_token=#{access_token}"))
    data = JSON(result)
    # WinwemediaLog::Base.logger('wxapi', "****** [Menu] wx_mp_user #{id} delete meun response: #{data}")

    if data['errcode'].to_i == 0
      update_attributes(is_sync: false)
    else
      return false
    end
  rescue => error
    WinwemediaLog::Base.logger('wxapi', "****** [Menu] wx_mp_user #{id} delete menu error: #{error.message}")
    return false
  end

  private

  def generate_token(column)
    self[column] = SecureRandom.hex(10)
  end

  def generate_code
    self.encoding_aes_key = WxMpUser.generate_key
    self.code = (Time.now.to_f * 1000_000).to_i.to_s
  end

  def generate_url
    host = Rails.env.production? ? 'http://api.wx.winwemedia.com' : "http://#{Settings.hostname}"
    user_code = code.blank? ? generate_code : code
    update_attributes(url: "#{host}/service/#{user_code}")
  end

  def format_data
    self.nickname              = nickname.to_s.strip
    self.app_id                = app_id.to_s.strip
    self.app_secret            = app_secret.to_s.strip
    self.encoding_aes_key      = encoding_aes_key.to_s.strip
    self.last_encoding_aes_key = encoding_aes_key_was if encoding_aes_key_changed?
  end

end
