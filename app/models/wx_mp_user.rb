# == Schema Information
#
# Table name: wx_mp_users
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  status        :integer          default(0), not null
#  name          :string(255)      not null
#  uid           :string(255)
#  token         :string(255)
#  url           :string(255)
#  user_type     :integer          default(1)
#  grant_type    :string(255)      default("client_credential")
#  is_sync       :boolean          default(FALSE)
#  app_id        :string(255)
#  app_secret    :string(255)
#  expires_in    :datetime
#  access_token  :string(255)
#  welcome_msg   :text
#  default_reply :text
#  username      :string(255)
#  password      :string(255)
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'uri'

class WxMpUser < ActiveRecord::Base
  include Concerns::WxMpUserPlugin

  validates :supplier_id, :status, :name, presence: true
  # validates :name, presence: true, uniqueness: { case_sensitive: false }
  # validates :uid, presence: true, on: :create
  serialize :func_info, JSON

  SHARE_PHOTO = [
    ["晒图", ActivityType::SHARE_PHOTO, "上传一张图片，试着根据提示操作创建自己的图片分享。"],
    ["退出晒图", ActivityType::EXIT_SHARE_PHOTO, "您已退出“图片分享”功能；\n重新进入请回复“{share_keyword}”。"],
    ["hi",ActivityType::OTHER_PHOTOS,"回复“{other_keyword}”，随机获取一张图片，多回多得。\n回复“{my_keyword}”，查看自己发的图片。\n回复“{exit_keyword}”，退出此功能。\n\n进去点个赞或评论一下吧。"],
    ["my" ,ActivityType::MY_PHOTOS, "my"]
  ]

  SUPPLIER_PRINT = [
    ["", ActivityType::SUPPLIER_PRINT, "您已进入打印图片模式，请发送图片给我；退出打印图片模式请回复：{退出打印}。"],
    ["", ActivityType::EXIT_SUPPLIER_PRINT, "您已经退出打印图片模式。"]
  ]

  WELOMO_PRINT = [
    ["", ActivityType::ENTER_WELOMO_PRINT, "您已进入打印图片模式，请发送图片给我；退出打印图片模式请回复：{退出打印}。"],
    ["", ActivityType::EXIT_WELOMO_PRINT, "您已经退出打印图片模式。"]
  ]

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

  belongs_to :supplier, inverse_of: :wx_mp_user

  has_one  :shop
  has_one  :website, conditions: { website_type: Website::MICRO_SITE }
  has_one  :life, class_name: 'Website', conditions: { website_type: Website::MICRO_LIFE }
  has_one  :vip_card
  has_one  :trip
  has_one  :share_photo_setting, inverse_of: :wx_mp_user
  has_one  :house, inverse_of: :wx_mp_user
  has_one  :wbbs_community
  has_one  :supplier_print_setting
  has_one  :welomo_print_setting

  has_many :wx_users, inverse_of: :wx_mp_user
  has_many :vip_users, inverse_of: :wx_mp_user
  has_many :wx_menus
  has_many :questions
  has_many :activities
  has_many :activity_consumes
  has_many :activity_users
  has_many :wx_replies
  has_many :ec_shops
  has_many :reservation_orders
  has_many :consumes
  has_many :qrcodes
  has_many :qrcode_logs

  before_create { generate_token(:token) }
  before_create :generate_code
  before_save :format_data
  after_create :generate_url
  after_update :check_reply

  def self.generate_key
    'vcl'+SecureRandom.hex(20)
  end

  def self.find_by_code_or_id_or_app_id(code, id, app_id)
    case
      when code.present?   then find_and_update_description(:code, code, nil, 1)
      when id.present?     then find_and_update_description(:id, id, '2', 1)
      when app_id.present? then find_and_update_description(:app_id, app_id, '3', 2)
    end
  end

  def self.find_and_update_description(field, value, description, bind_type)
    mp_user = WxMpUser.where(field => value).first
    return unless mp_user

    mp_user.attributes = {description: description, bind_type: bind_type}
    mp_user.save if mp_user.changed?
    mp_user
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

  def update_uid_to(openid = nil)
    if openid.present? && uid != openid
      WxMpUser.where(uid: openid).where('id != ?', id).update_all(uid: "#{uid}_#{Time.now.to_i}", app_id: "#{app_id}_#{Time.now.to_i}")
      update_attributes(uid: openid)
    end
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

  def first_follow_reply
    wx_replies.click_event.first rescue nil
  end

  def text_reply
    wx_replies.text_event.first rescue nil
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
      result = RestClient.get(URI::encode("https://api.weixin.qq.com/cgi-bin/token?grant_type=#{grant_type}&appid=#{app_id}&secret=#{app_secret}"))
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

  def pingable?
    result = RestClient.get(URI::encode("https://api.weixin.qq.com/cgi-bin/token?grant_type=#{grant_type}&appid=#{app_id}&secret=#{app_secret}"))
    data = JSON(result)
    data['errcode'].to_i == 0
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

  def new_activity_for_wbbs_community
    create_activity_for(ActivityType::WBBS_COMMUNITY, Activity::SETTED, "微社区", "微社区")

    now = Time.now
    attrs = {
      supplier_id: supplier_id,
      wx_mp_user_id: id,
      activity_type_id: 49,
    }
    full_attrs = {
      status: 1,
      name: "微社区",
      keyword: "微社区",
      ready_at: now,
      start_at: now,
      end_at: now+100.years
    }
    Activity.where(attrs).new(full_attrs)
  end

  def new_activity_for_scene
    now = Time.now
    attrs = {
      supplier_id: supplier_id,
      wx_mp_user_id: id,
      activity_type_id: 73,
    }
    full_attrs = {
      status: 1,
      name: "微场景",
      keyword: "微场景",
      ready_at: now,
      start_at: now,
      end_at: now+100.years
    }
    Activity.where(attrs).new(full_attrs)
  end

  def new_activity_for_guess
    now = Time.now
    attrs = {
      supplier_id: supplier_id,
      wx_mp_user_id: id,
      activity_type_id: ActivityType::GUESS
    }
    full_attrs = {
      status: 0,
      name: "美图猜猜",
      keyword: "美图猜猜"
    }
    Activity.where(attrs).new(full_attrs)
  end

  def create_activity_for_fans_game
    activity = Activity.where(
      supplier_id: supplier_id,
      wx_mp_user_id: id,
      activity_type_id: 67,
    ).first_or_create(status: 1, name: "营销游戏", keyword: "营销游戏", summary: '')

    FansGame.pluck(:id).each{|id| activity.activities_fans_games.where(fans_game_id: id).first_or_create }

    activity
  end

  def create_activity_for_wedding
    attrs, full_attrs = initiate_activity_for(ActivityType::WEDDINGS, Activity::SETTED, "微婚礼", "微婚礼")
    Activity.new(full_attrs)
  end

  def create_activity_for_website
    create_activity_for(ActivityType::WEBSITE, Activity::SETTED, "微官网", "微官网", qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key)
  end

  def create_activity_for_vip_card
    create_activity_for(ActivityType::VIP, Activity::SETTED, "会员卡", "会员卡")
  end

  def create_activity_for_ktv_orders
    create_activity_for(ActivityType::KTV_ORDER, Activity::SETTED, "KTV预订", "KTV预订")
  end

  def create_activity_for_govchat
    create_activity_for(ActivityType::GOVCHAT, Activity::SETTED, "微信互动", "微政务微信互动", summary: '请点击进入微政务微信互动')
  end

  def create_activity_for_govmail
    create_activity_for(ActivityType::GOVMAIL, Activity::SETTED, "信访大厅", "微政务信访大厅", summary: '请点击进入微政务信访大厅')
  end

  def create_activity_for_coupon
    create_activity_for(ActivityType::COUPON, Activity::SETTED, "优惠券", "优惠券", summary: '请点击进入电子优惠券')
  end

  def create_activity_for_college
    create_activity_for(ActivityType::EDUCATIONS, Activity::SETTED, "微教育", "微教育")
  end

  def create_activity_for_house_bespeak
    create_activity_for(ActivityType::HOUSE_BESPEAK, Activity::SETTED, '预约看房', '预约看房')
  end

  def create_activity_for_house_seller
    create_activity_for(ActivityType::HOUSE_SELLER, Activity::SETTED, '房产销售顾问', '房产销售顾问')
  end

  def create_activity_for_house_impression
    create_activity_for(ActivityType::HOUSE_IMPRESSION, Activity::SETTED, '房友印象', '房友印象')
  end

  def create_activity_for_house_live_photo
    create_activity_for(ActivityType::HOUSE_LIVE_PHOTO, Activity::SETTED, '实景拍摄', '实景拍摄')
  end

  def create_activity_for_house_intro
    create_activity_for(ActivityType::HOUSE_INTRO, Activity::SETTED, '楼盘简介', '楼盘简介')
  end

  def create_activity_for_house_review
    create_activity_for(ActivityType::HOUSE_REVIEW, Activity::SETTED, '专家点评', '专家点评')
  end

  def create_activity_for_shop(activity_type_id, attrs = {})
    activity_types = { 6 => '微订餐', 7 => '微订座', 9 => '微外卖', 11 => '微门店' }
    activity_type_name = activity_types[activity_type_id]
    create_activity_for(activity_type_id, Activity::SETTED, activity_type_name, activity_type_name, {qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key}.merge!(attrs) )
  end

  def create_activity_for_share_photo_setting
    transaction do
      attrs = {supplier_id: supplier_id, wx_mp_user_id: id, name: '晒图', upload_description: "图片上传成功，试着给它打个标签吧，输入汉字“标签”+与图片相对应的属性，如：\n标签 丽江\n标签 火锅\n标签 西湖", add_tag_description: "回复“{other_keyword}”，获取一张其他人的晒图，多回多得。\n继续晒图，请直接上传图片，回复“{my_keyword}”,查看自己发的图片。\n回复“{exit_keyword}”，退出此功能。\n\n点击查看你晒的图有多少人赞。" }
      share_photo_setting = SharePhotoSetting.where(attrs).first_or_create

      SHARE_PHOTO.each do |value|
        now = Time.now
        attrs = {
          supplier_id:      supplier_id,
          wx_mp_user_id:    id,
          activity_type_id: value[1]
        }
        full_attrs = {
          activityable_id: share_photo_setting.id,
          activityable_type: 'SharePhotoSetting',
          status:   WxMpUser::ACTIVE,
          name:     value[0],
          keyword:  value[0],
          summary:  value[2],
          #qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
          ready_at: now,
          start_at: now,
          end_at:   now + 100.years
        }.merge! attrs
        Activity.where(attrs).first || Activity.create!(full_attrs)
      end

      share_photo_setting
    end
  end

  def build_activity_for_welomo_print_setting
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id, name: '微打印' }
    #创建设置
    supplier_print_setting = SupplierPrintSetting.where(attrs).first_or_create
    WELOMO_PRINT.each do |value|
      now = Time.now
      attrs = {
          supplier_id:      supplier_id,
          wx_mp_user_id:    id,
          activity_type_id: value[1]
      }
      full_attrs = {
          activityable_id: supplier_print_setting.id,
          activityable_type: 'SupplierPrintSetting',
          status:   WxMpUser::ACTIVE,
          name:     value[0],
          keyword:  value[0],
          summary:  value[2],
          ready_at: now,
          start_at: now,
          end_at:   now + 100.years
      }.merge! attrs
      supplier_print_setting.activities << Activity.new(full_attrs)
    end
    supplier_print_setting.activities = supplier_print_setting.welomo
    supplier_print_setting
  end

  def build_activity_for_supplier_print_setting
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id, name: '微信打印' }
    #创建设置
    supplier_print_setting = SupplierPrintSetting.where(attrs).first_or_create
    SUPPLIER_PRINT.each do |value|
      now = Time.now
      attrs = {
          supplier_id:      supplier_id,
          wx_mp_user_id:    id,
          activity_type_id: value[1]
      }
      full_attrs = {
          activityable_id: supplier_print_setting.id,
          activityable_type: 'SupplierPrintSetting',
          status:   WxMpUser::ACTIVE,
          name:     value[0],
          keyword:  value[0],
          summary:  value[2],
          ready_at: now,
          start_at: now,
          end_at:   now + 100.years
      }.merge! attrs
      supplier_print_setting.activities << Activity.new(full_attrs)
    end
    supplier_print_setting.activities = supplier_print_setting.inlead
    supplier_print_setting
  end

  def create_share_photo_setting
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id }
    share_photo_setting = SharePhotoSetting.where(attrs).first_or_create(name: '晒图')
  end


  def build_album_activity(attrs = {})
    attrs = {
      activity_type_id: ActivityType::ALBUM,
      supplier_id: supplier_id,
      status: 1
    }.merge!(attrs)
    attrs[:qiniu_pic_key] ||= 'Fg9Vd6nvy6j6mb_D8yPQ09ZwY9qZ'
    activities.build(attrs)
  end

  def build_greet_activity(options = {})
    now = Time.now
    attrs = {
      activity_type_id: ActivityType::GREET,
      supplier_id: supplier_id,
      wx_mp_user_id: id,
      status: 1
    }

    full_attrs = {
        name: '微贺卡',
        keyword: '微贺卡',
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge!(options)
    full_attrs[:qiniu_pic_key] ||= 'FqBarADTwYkTW2EFVaA43PW_0rSu'

    activity = Activity.where(attrs).first || Activity.create!(attrs.merge!(full_attrs))

    attrs = {
        supplier_id: supplier_id,
        wx_mp_user_id: id,
        activity_id: activity.id
    }

    Greet.where(attrs).first || Greet.create!(attrs)
    activity
  end

  def create_life
    attrs = { website_type: Website::MICRO_LIFE, supplier_id: supplier_id, wx_mp_user_id: id }
    life = Website.where(attrs).first_or_create(name: '微生活')

    now = Time.now
    attrs = {
      supplier_id:      supplier_id,
      wx_mp_user_id:    id,
      activity_type_id: ActivityType::LIFE
    }
    full_attrs = {
      activityable_id: life.id,
      activityable_type: 'Website',
      status:   WxMpUser::ACTIVE,
      name:     life.name,
      keyword:  life.name,
      description:  life.name,
      qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now,
      start_at: now,
      end_at:   now + 100.years
    }.merge! attrs
    activity = Activity.where(attrs).first || Activity.create!(full_attrs)
    life.update_column(:activity_id, activity.id)
    life
  end

  def create_circle
    attrs = { website_type: Website::MICRO_CIRCLE, supplier_id: supplier_id, wx_mp_user_id: id }
    circle = Website.where(attrs).first_or_create(name: '微商圈')

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::CIRCLE
    }
    full_attrs = {
        activityable_id: circle.id,
        activityable_type: 'Website',
        status:   WxMpUser::ACTIVE,
        name:     circle.name,
        keyword:  circle.name,
        description:  circle.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    activity = Activity.where(attrs).first || Activity.create!(full_attrs)
    circle.update_column(:activity_id, activity.id)
    circle
  end

  def create_hospital
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id}

    hospital = Hospital.where(attrs).first_or_create( name: '微医疗' )

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::HOSPITAL
    }
    full_attrs = {
        activityable_id: hospital.id,
        activityable_type: 'Hospital',
        status:   WxMpUser::ACTIVE,
        name:     hospital.name,
        keyword:  hospital.name,
        description:  hospital.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || create_activity_hospital_job_title(full_attrs, hospital)

    hospital
  end

  def create_activity_hospital_job_title(full_attrs, hospital)
    Activity.create!(full_attrs)
    %w(教授 博士 导师 主任).each do |job_title|
      HospitalJobTitle.create!(name: job_title, wx_mp_user_id: full_attrs[:wx_mp_user_id] , hospital_id: hospital.id, description: job_title, supplier_id: full_attrs[:supplier_id])
    end
  end

  def create_shop
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id }

    ec_shop = EcShop.where(attrs).first_or_create(name: '微电商')

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::EC
    }
    full_attrs = {
        activityable_id: ec_shop.id,
        activityable_type: 'EcShop',
        status:   WxMpUser::ACTIVE,
        name:     ec_shop.name,
        keyword:  ec_shop.name,
        description:  ec_shop.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    ec_shop
  end

  def create_booking
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id }

    booking = Booking.where(attrs).first_or_create(name: '微服务')

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::BOOKING
    }
    full_attrs = {
        activityable_id: booking.id,
        activityable_type: 'Booking',
        status:   WxMpUser::ACTIVE,
        name:     booking.name,
        keyword:  booking.name,
        description:  booking.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    booking
  end

  def create_group
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id }

    group = Group.where(attrs).first_or_create( name: '团购' )

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::GROUP
    }
    full_attrs = {
        activityable_id: group.id,
        activityable_type: 'Group',
        status:   WxMpUser::ACTIVE,
        name:     group.name,
        keyword:  '支付版团购',
        description:  group.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    group
  end

  def create_broche
    attrs = {supplier_id: supplier_id, wx_mp_user_id: id }

    broche = Broche.where(attrs).first_or_create( name: '微楼书' )

    now = Time.now
    attrs = {
        supplier_id:      supplier_id,
        wx_mp_user_id:    id,
        activity_type_id: ActivityType::BROCHE
    }
    full_attrs = {
        activityable_id: broche.id,
        activityable_type: 'Broche',
        status:   WxMpUser::ACTIVE,
        name:     broche.name,
        keyword:  broche.name,
        description:  broche.name,
        qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    broche
  end

  def build_activity_for(activity_type_id, status, name, keyword)
    full_attrs = initiate_activity_for(activity_type_id, status, name, keyword).last
    Activity.new(full_attrs)
  end

  private

  def check_reply
    if welcome_msg_changed?
      attrs = { event_type: WxReply::CLICK_EVENT, reply_type: WxReply::TEXT, content: welcome_msg }
      if first_follow_reply
        first_follow_reply.update_attributes(attrs)
      else
        wx_replies.first_or_create(attrs)
      end
    end
  end

  def generate_token(column)
    self[column] = SecureRandom.hex(10)
  end

  def generate_code
    self.key = WxMpUser.generate_key
    self.code = (Time.now.to_f * 1000_000).to_i.to_s
  end

  def generate_url
    host = Rails.env.production? ? 'http://proxy.weixin.winwemedia.com' : "http://#{Settings.hostname}"
    user_code = code.blank? ? generate_code : code
    update_attributes(url: "#{host}/server/#{user_code}")
  end

  def format_data
    self.name                  = name.to_s.strip
    self.app_id                = app_id.to_s.strip
    self.app_secret            = app_secret.to_s.strip
    self.encoding_aes_key      = encoding_aes_key.to_s.strip
    self.last_encoding_aes_key = encoding_aes_key_was if encoding_aes_key_changed?
  end

  def create_activity_for(activity_type_id, status, name, keyword, extend_attrs = {})
    attrs, full_attrs = initiate_activity_for(activity_type_id, status, name, keyword, extend_attrs)

    Activity.where(attrs).first || Activity.create!(full_attrs)
  end

  def initiate_activity_for(activity_type_id, status, name, keyword, extend_attrs = {})
    now = Time.now
    default_attrs = {
      supplier_id:      supplier_id,
      wx_mp_user_id:    id,
      activity_type_id: activity_type_id
    }
    full_attrs = {
      status:   status,
      name:     name,
      keyword:  keyword,
      # qiniu_pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now+1.seconds,
      start_at: now+1.seconds,
      end_at:   now + 100.years
    }
    full_attrs.merge!(default_attrs)
    full_attrs.merge!(extend_attrs) if extend_attrs.present?

    [default_attrs, full_attrs]
  end

  def negative_vip_users_supplier_id
    vip_users.update_all(wx_mp_user_id: -Time.now.to_i, supplier_id: -supplier_id.abs) rescue nil
  end

end
