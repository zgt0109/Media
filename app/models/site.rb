class Site < ActiveRecord::Base
  include AccountPermissions
  include Concerns::Brokerages
  include Concerns::RedPackets

  SHARE_PHOTO = [
    ["晒图", ActivityType::SHARE_PHOTO, "上传一张图片，试着根据提示操作创建自己的图片分享。"],
    ["退出晒图", ActivityType::EXIT_SHARE_PHOTO, "您已退出“图片分享”功能；\n重新进入请回复“{share_keyword}”。"],
    ["hi",ActivityType::OTHER_PHOTOS,"回复“{other_keyword}”，随机获取一张图片，多回多得。\n回复“{my_keyword}”，查看自己发的图片。\n回复“{exit_keyword}”，退出此功能。\n\n进去点个赞或评论一下吧。"],
    ["my" ,ActivityType::MY_PHOTOS, "my"]
  ]

  WX_PRINT = [
    ["", ActivityType::WX_PRINT, "您已进入打印图片模式，请发送图片给我；退出打印图片模式请回复：{退出打印}。"],
    ["", ActivityType::EXIT_WX_PRINT, "您已经退出打印图片模式。"]
  ]

  enum_attr :status, :in => [
    ['pending', 0, '待审核'],
    ['active',  1, '正常'],
    ['froze',  -1, '已冻结']
  ]

  belongs_to  :account
  belongs_to  :account_footer
  belongs_to  :piwik_site

  has_one :wx_mp_user, inverse_of: :site
  has_one :shop, inverse_of: :site

  has_many :assistants_sites
  has_many :assistants, through: :assistants_sites
  has_many :replies
  has_many :keywords
  has_many :activity_consumes
  has_many :consumes

  has_many  :users, inverse_of: :site
  has_many  :wx_users, through: :wx_mp_user
  has_one  :house
  has_one  :car_shop
  has_one  :hotel
  has_one  :website, conditions: { website_type: Website::MICRO_SITE }
  has_one  :life, class_name: 'Website', conditions: { website_type: Website::MICRO_LIFE }
  has_one  :circle, class_name: 'Website', conditions: { website_type: Website::MICRO_CIRCLE }
  has_one  :vip_card
  has_one  :trip
  has_many  :trip_ticket_categories
  has_many :trip_tickets
  has_one  :share_photo_setting
  has_one  :wx_plot
  # has_one :activity_wx_plot_bulletin, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_BULLETIN }
  # has_one :activity_wx_plot_repair, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_REPAIR }
  # has_one :activity_wx_plot_complain, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_COMPLAIN }
  # has_one :activity_wx_plot_owner, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_OWNER }
  # has_one :activity_wx_plot_life, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_LIFE }
  # has_one :activity_wx_plot_telephone, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_TELEPHONE }
  has_many :wbbs_communities
  has_many :reservation_orders
  has_many :wbbs_topics
  has_many :share_photos
  has_many :vip_groups, through: :vip_card
  has_many :vip_grades, through: :vip_card
  has_many :vip_message_plans, through: :vip_card
  has_many :vip_users, inverse_of: :site
  has_many :vip_privileges, through: :vip_card
  has_many :wx_menus
  has_many :materials
  has_many :activities
  has_many :activity_users
  has_many :questions
  has_many :answers
  has_one  :shop
  has_many :shop_branches
  has_many :shop_branch_sub_accounts, through: :shop_branches, source: :sub_account, conditions: "shop_branches.status = #{ShopBranch::USED}"
  has_many :shop_orders
  has_many :shop_table_orders
  has_many :shop_categories
  has_many :shop_table_settings
  has_many :shop_order_reports
  has_many :fight_questions
  has_many :guess_questions, class_name: 'Guess::Question'
  has_many :fight_papers
  has_many :fight_report_cards
  has_many :feedbacks
  has_many :weddings
  has_many :albums
  has_many :donations
  has_many :donation_orders, :through => :donations
  has_many :greets
  has_one  :hospital
  has_many :hospital_orders
  has_many :hospital_departments
  has_many :hospital_job_titles
  has_many :hospital_doctors
  has_many :hospital_comments
  has_one  :college
  has_one  :ec_shop
  has_many :ec_seller_cats
  has_many :ec_items
  has_one  :booking
  has_many :booking_ads
  has_many :booking_categories
  has_many :booking_items
  has_many :booking_orders
  has_many :ktv_orders
  has_one  :group
  has_many :group_categories
  has_many :group_items
  has_many :group_orders
  has_one  :api_user

  has_many :point_gifts, dependent: :destroy
  has_many :point_gift_exchanges, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :point_types, dependent: :destroy
  has_many :vip_user_messages, dependent: :destroy
  has_many :vip_user_transactions, dependent: :destroy
  has_many :vip_packages
  has_many :vip_package_item_consumes
  has_many :vip_packages_vip_users
  has_many :vip_external_http_apis
  has_many :vip_importings

  has_many :leaving_messages, dependent: :destroy
  has_many :leaved_messages,  dependent: :destroy, class_name: 'LeavingMessage', as: :replier
  has_many :share_photo_comments
  has_many :share_photo_likes
  has_many :share_photos
  has_one  :share_photo_setting
  has_many :payment_settings

  has_one :car_brand, dependent: :destroy
  has_many :car_bespeaks, dependent: :destroy
  has_many :car_sellers, dependent: :destroy
  has_many :car_brands, dependent: :destroy
  has_many :car_catenas, dependent: :destroy
  has_many :car_activity_notices, dependent: :destroy
  has_many :wx_walls, dependent: :destroy
  has_many :qrcode_channel_types, dependent: :destroy
  has_many :qrcode_channels, dependent: :destroy
  has_many :qrcode_logs, dependent: :destroy
  has_many :qrcode_users, dependent: :destroy

  has_many :shakes
  has_many :shake_rounds
  has_many :shake_prizes
  has_many :shake_users
  has_many :system_messages, order: 'created_at DESC'
  has_many :system_message_settings
  has_one  :broche

  accepts_nested_attributes_for :car_activity_notices, :wx_plot, :system_message_settings

  has_many :payments#, as: :customer

  has_many :panoramagrams

  has_many :red_packets, class_name: 'RedPacket::RedPacket'

  before_create :add_default_attrs

  def self.current
    Thread.current[:site]
  end

  def self.current=(site)
    Thread.current[:site] = site
  end

  def update_all_system_messages
    if system_messages.unread.update_all(is_read: true) > 0
      uri = URI.parse("http://#{FAYE_HOST}/faye")
      Net::HTTP.post_form(uri, message: {channel: "/system_messages/change/#{id}", data: {operate: 'delete_all'}}.to_json)
    end
  end

  def has_privilege_for?(id)
    return true unless Rails.env.production?
    privileges.to_s.split(',').uniq.include?(id.to_s)
  end

  def find_or_generate_auth_token(encrypt = true)
    update_attributes(token: SecureRandom.urlsafe_base64(60)) unless token.present?
    encrypt ? Des.encrypt(self.token) : self.token
  end

  def uid
    @uid ||= self.wx_mp_user.try(:openid)
  end

  def wx_logs_by_date(date)
    WxLog.by_date(date).by_uid(self.uid)
  end

  def expired?
    expired_at.nil? || expired_at < Time.now
  end

  def can_pay?
    payment_settings.present?
  end

  def can_show_introduce?
    false
    # trial_account?# || free_account?
  end

  def can_recharge?
    enabled_payment_setting_types.count > 0
  end

  def need_auth_mobile?
    auth_mobile.to_i != 1 && agent_id != 10656
  end

  def enabled_payment_settings
    payment_settings.enabled
  end

  def enabled_payment_types
    payment_settings.enabled.map(&:payment_type).map(&:id_name)
  end

  def enabled_payment_setting_types
    @enabled_payment_setting_types ||= enabled_payment_settings.pluck(:type)
  end

  def album_activity
    @album_activity ||= activities.where(activity_type_id: ActivityType::ALBUM).first
  end

  def greet_activity
    @greet_activity ||= activities.where(activity_type_id: ActivityType::GREET).first
  end

  def donation_activity
    @donation_activity ||= activities.where(activity_type_id: ActivityType::DONATION).first
  end

  def piwik_entry_pages_labels
    memkey = "Account_piwik_entry_pages_labels_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      request = {}
      if PiwikSite.token_auth && self.piwik_site_id.to_i > 0
        apis = ["http://#{PiwikSite.server}/?format=json&module=API&token_auth=#{PiwikSite.token_auth}"]
        apis << "&method=Actions.getEntryPageUrls&idSite=#{self.piwik_site_id}&period=year&date=today"
        Rails.logger.info "Request url: #{apis.join("&")}"
        request = JSON.parse(RestClient.get(apis.join("&")))
      end
      request
    end
  end

  def piwik_entry_pages_urls(idSubtable)
    memkey = "Account_piwik_entry_pages_urls_#{idSubtable}_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      request = {}
      if PiwikSite.token_auth && self.piwik_site_id.to_i > 0
        apis = ["http://#{PiwikSite.server}/?format=json&module=API&token_auth=#{PiwikSite.token_auth}"]
        apis << "&method=Actions.getEntryPageUrls&idSite=#{self.piwik_site_id}&period=year&date=today&idSubtable=#{idSubtable}"
        Rails.logger.info "Request url: #{apis.join("&")}"
        request = JSON.parse(RestClient.get(apis.join("&")))
      end
      request
    end
  end

  def hour_piwik_data(date)
    memkey = "Account_hour_piwik_data_#{date}_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      request = []
      if PiwikSite.token_auth && self.piwik_site_id.to_i > 0
        apis = ["http://#{PiwikSite.server}/?format=json&module=API&token_auth=#{PiwikSite.token_auth}"]
        apis << "&method=VisitTime.getVisitInformationPerServerTime&idSite=#{self.piwik_site_id}&period=day&date=#{date.to_s}"
        Rails.logger.info "Request url: #{apis.join("&")}"
        request = JSON.parse(RestClient.get(apis.join("&")))
        request = [] if request.is_a?(Hash) && request["result"] == "error"
      end
      request
    end
  end

  def daily_piwik_data(date)
    memkey = "Account_daily_piwik_data_#{date}_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      request = {}
      if PiwikSite.token_auth && self.piwik_site_id.to_i > 0
        apis = ["http://#{PiwikSite.server}/?format=json&module=API&token_auth=#{PiwikSite.token_auth}"]
        apis << "&method=VisitsSummary.get&idSite=#{self.piwik_site_id}&period=day&date=#{date.to_s}"
        Rails.logger.info "Request url: #{apis.join("&")}"
        request = JSON.parse(RestClient.get(apis.join("&")))
      end
      request
    end
  rescue => error
    {}
  end

  def piwik_by_date(date)
    memkey = "Account_daily_piwik_data_#{date}_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      piwik_sites.where(date: date).first
    end
  rescue => error
    nil
  end

  def bounce_rate
    memkey = "Account_bounce_rate_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      _bounce_rates = PiwikSite.where(:site_id => self.id).limit(30).pluck(:bounce_rate)
      _bounce_rates.count.zero? ? 0.0 : (_bounce_rates.sum / _bounce_rates.count).round(2) rescue 0.0
    end
  end

  def avg_time_on_site
    memkey = "Account_avg_time_on_site_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      _avg_time_on_sites = PiwikSite.where(:site_id => self.id).limit(30).pluck(:avg_time_on_site)
      _avg_time_on_sites.count.zero? ? 0.0 : (_avg_time_on_sites.sum / _avg_time_on_sites.count).round(2) rescue 0.0
    end
  end

  def save_daily_piwik_data(date)
    daily_data = daily_piwik_data(date)
    if daily_data.present? && daily_data["result"] != "error"
      piwik = PiwikSite.where(:date => date, :site_id => self.id).first_or_create
      daily_data.each do |key, value|
        piwik.try("#{key}=", value) if PiwikSite.attribute_names.include?(key)
      end
      piwik.save
    end
  end

  # 输出 Piwik js统计代码
  def piwik_js_code
    if PiwikSite.server.present? && self.piwik_site_id.to_i > 0
      js_code = <<START
      <!-- tongji code -->
      <script type="text/javascript">
        var _paq = _paq || [];
        _paq.push(['trackPageView']);
        _paq.push(['enableLinkTracking']);
        (function() {
          var u=(("https:" == document.location.protocol) ? "https" : "http") + "://#{PiwikSite.server}/";
          _paq.push(['setTrackerUrl', u+'piwik.php']);
          _paq.push(['setSiteId', #{self.piwik_site_id}]);
          var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0]; g.type='text/javascript';
          g.defer=true; g.async=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
        })();

      </script>
      <noscript><p><img src="http://#{PiwikSite.server}/piwik.php?idsite=#{self.piwik_site_id}" style="border:0;" alt="" /></p></noscript>
      <!-- end tongji code -->
START
    else
      js_code = ""
    end
    js_code.html_safe
  end

  def giving_points(amount, type, params, vip_user, pay: true)
    point_type = point_types.normal.greatest.where(category: type).find do |point_type|
      amount >= point_type.amount
    end
    vip_privilege = vip_user.usable_privileges.where(category: type).point.underway.greatest_value.find do |vip_privilege|
      amount >= vip_privilege.amount.to_f && vip_privilege.point_unlimited?(vip_user)
    end
    points = vip_privilege.try(:value).present? ? (point_type.try(:points).to_i * vip_privilege.value) : point_type.try(:points).to_i
    points *= (amount / point_type.amount).to_i if point_type.try(:accumulative?)
    point_transactions.create(direction_type: params[:direction], points: points, vip_user: vip_user, point_type_id: point_type.id, description: (params[:description].presence || (params[:direction].to_i == 3 ? "充值金额赠送" : "消费金额赠送")), pointable: vip_privilege, shop_branch_id: params[:current_shop_branch_id]) if pay && point_type
    points
  end

  # 获取统计网站的 site_id
  def get_piwik_site_id
    if PiwikSite.token_auth && self.piwik_site_id.to_i == 0
      path = self.website.try(:domain).to_s
      executes = []
      apis = ["http://#{PiwikSite.server}/?format=json&module=API&token_auth=#{PiwikSite.token_auth}&method=SitesManager.addSite&siteName=#{URI::escape(self.nickname)}&urls[0]=#{PiwikSite.domain}#{self.id}"]
      if path.present?
        apis << "urls[1]=#{PiwikSite.domain}#{path}"
        # piwik_domain_status 属性含义： 0 没有个性化域名 1 有个性化域名但未添加到统计网站 2 有个性化域名并且已添加到统计网站
        executes << "piwik_domain_status = 2"
      end
      Rails.logger.info "Request url: #{apis.join("&")}"
      request = JSON.parse(RestClient.get(apis.join("&")))
      executes << "piwik_site_id = #{request["value"]}" if request["value"].to_i > 0
      # 为了不因为 nickname 重复等原因保存失败，采用这种方式保存
      Account.update_all(executes.join(","), ["id = ?", self.id])
    end
  rescue Exception => e
    Rails.logger.info "Account.get_piwik_site_id ERROR: #{e}"
  end

  def add_default_attrs
    # if self.is_reg_web #如果是前台自助申请试用的
      privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023,
        1030, 1031, 1032,
        1040, 1041, 1042, 1043,
        1050,
        1, 2,
        5000, 4, 5, 8, 25, 28, 33, 62, 64, 67, 70, 71, 75, 76, 77, 78, 82, 83,
        6000, 10, 12, 15, 19, 24, 37, 49, 63, 73, 74,
        11, 14, 30, 38, 55,
        10007,
      ]

      self.status = 1
      self.privileges = privileges.join(',')
      # self.expired_at = (created_at || Time.now) + 30.days #试用期30天
    # end
  end

  def update_expired_privileges
    return if free_account?
    # return unless expired?

    site_apps.clear

    privileges = [
      1000, 1001, 1002, 1003,
      1010, 1011, 1012, 1013, 1014, 1015,
      1020, 1021, 1022, 1023,
      1030, 1031, 1032,
      1,
      5000, 4, 62,
      6000, 73,
    ]

    attrs = {
      privileges: privileges.join(','),
      custom_privileges: nil,
      site_product_id: 10000,
      site_industry_id: 1000,
      is_gift: false,
      account_type: 5,
      upgrade_type: normal_account? ? NORMAL_CHANGE_FREE : TRIAL_CHANGE_FREE,
      upgrade_at: Time.now
    }
    update_attributes(attrs)
  end

  def update_privileges

    if expired? or free_account?
      new_privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023,
        1030, 1031, 1032,
        1,
        5000, 4, 62,
        6000, 73,
      ]
    elsif site_product_id == 10006
      new_privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023,
        1030, 1031, 1032,
        1040, 1041, 1042, 1043,
        1050,
        1, 2,
        5000,
        6000, 73,
        11, 14, 30,
        10007,
      ]
    elsif site_product_id == 12000
      new_privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        6000, 73,
        10007,
      ]
    else
      new_privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023,
        1030, 1031, 1032,
        1040, 1041, 1042, 1043,
        1050,
        1, 2,
        5000, 4, 5, 8, 25, 28, 33, 62, 64, 67, 70, 71, 75, 76, 77, 78, 82, 83,
        6000, 10, 12, 15, 19, 24, 37, 49, 63, 73, 74,
        11, 14, 30, 38, 55,
        10007,
      ]
    end

    if site_product_id == 10006
      new_custom_privileges = site_industry_ids + [site_industry_id] + custom_privileges.to_s.split(',').map(&:to_i)
    else
      new_custom_privileges = site_industry_ids + [site_industry_id]
    end

    update_attributes(privileges: new_privileges.uniq.join(','), custom_privileges: new_custom_privileges.uniq.join(','))
  end

  def send_kf_msg wx_user,content
    mp_user = self.wx_mp_user
    return '' unless mp_user
    mp_user.auth! if mp_user.auth_expired?

    json = "{\"touser\":\"#{wx_user.openid}\",\"msgtype\":\"text\",\"text\": { \"content\":\"#{content}\" }}"
    result = RestClient.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}", json, :content_type => :json, :accept => :json)
    logger.info "===============================#{result}================="
    #result =~ /"errcode":40001/# ? raise : JSON(result)
    if result =~ /"errcode":40001/
      mp_user.auth!
      result = RestClient.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}", json, :content_type => :json, :accept => :json)
    end
  rescue
    #mp_user.auth!
    #result = RestClient.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}", json, :content_type => :json, :accept => :json)
  end

  # site.delay.init_website_data
  def init_website_data
    if Rails.env.staging? || Rails.env.production?
      site_id = 10001
    else
      site_id = 10001
    end
    from_site = Site.where(id: site_id).first || Site.first
    return puts "user not exists" unless from_site

    user_cloner = UserCloner.new(from_user.nickname)
    user_cloner.user = self
    return puts "wx_mp_user not exists" unless self.wx_mp_user

    # 初始化公众号和微官网
    # wx_mp_user = create_wx_mp_user!(name: nickname) unless wx_mp_user
    # wx_mp_user.create_activity_for_website

    user_cloner.wx_mp_user = self.wx_mp_user

    user_cloner.clone_website
    user_cloner.clone_shops
    user_cloner.init_activity_by_coupon
    user_cloner.clone_activity_by_marketing(:gua)
    user_cloner.init_activity_by_fans_game
  end

  def new_activity_for_wbbs_community
    create_activity_for(ActivityType::WBBS_COMMUNITY, Activity::SETTED, "微社区", "微社区")

    now = Time.now
    attrs = {
      site_id: id,
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
      site_id: id,
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
      site_id: id,
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
      site_id: id,
      activity_type_id: 67,
    ).first_or_create(status: 1, name: "营销游戏", keyword: "营销游戏", summary: '')

    FansGame.normal.pluck(:id).each{|id| activity.activities_fans_games.where(fans_game_id: id).first_or_create }

    activity
  end

  def create_activity_for_wedding
    attrs, full_attrs = initiate_activity_for(ActivityType::WEDDINGS, Activity::SETTED, "微婚礼", "微婚礼")
    Activity.new(full_attrs)
  end

  def create_activity_for_website
    create_activity_for(ActivityType::WEBSITE, Activity::SETTED, "微官网", "微官网", pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key)
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
    create_activity_for(activity_type_id, Activity::SETTED, activity_type_name, activity_type_name, {pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key}.merge!(attrs) )
  end

  def create_activity_for_share_photo_setting
    transaction do
      attrs = {site_id: id, name: '晒图', upload_description: "图片上传成功，试着给它打个标签吧，输入汉字“标签”+与图片相对应的属性，如：\n标签 丽江\n标签 火锅\n标签 西湖", add_tag_description: "回复“{other_keyword}”，获取一张其他人的晒图，多回多得。\n继续晒图，请直接上传图片，回复“{my_keyword}”,查看自己发的图片。\n回复“{exit_keyword}”，退出此功能。\n\n点击查看你晒的图有多少人赞。" }
      share_photo_setting = SharePhotoSetting.where(attrs).first_or_create

      SHARE_PHOTO.each do |value|
        now = Time.now
        attrs = {
          site_id: id,
          activity_type_id: value[1]
        }
        full_attrs = {
          activityable_id: share_photo_setting.id,
          activityable_type: 'SharePhotoSetting',
          status:   Activity::SETTED,
          name:     value[0],
          keyword:  value[0],
          summary:  value[2],
          #pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
          ready_at: now,
          start_at: now,
          end_at:   now + 100.years
        }.merge! attrs
        Activity.where(attrs).first || Activity.create!(full_attrs)
      end

      share_photo_setting
    end
  end

  def build_activity_for_print
    print = Print.where(account_id: account_id).first_or_create

    WX_PRINT.each do |value|
      now = Time.now
      attrs = {
        site_id: id,
        activity_type_id: value[1]
      }
      full_attrs = {
        activityable_id: print.id,
        activityable_type: 'Print',
        status:   Activity::SETTED,
        name:     value[0],
        keyword:  value[0],
        summary:  value[2],
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
      }.merge! attrs
      print.activities << Activity.new(full_attrs)
    end
    print.activities = print.printers
    print
  end

  def create_share_photo_setting
    share_photo_setting = SharePhotoSetting.where({ site_id: id }).first_or_create(name: '晒图')
  end


  def build_album_activity(attrs = {})
    attrs = {
      activity_type_id: ActivityType::ALBUM,
      site_id: id,
      status: 1
    }.merge!(attrs)
    attrs[:pic_key] ||= 'Fg9Vd6nvy6j6mb_D8yPQ09ZwY9qZ'
    activities.build(attrs)
  end

  def build_greet_activity(options = {})
    now = Time.now
    attrs = {
      activity_type_id: ActivityType::GREET,
      site_id: id,
      status: 1
    }

    full_attrs = {
      name: '微贺卡',
      keyword: '微贺卡',
      ready_at: now,
      start_at: now,
      end_at:   now + 100.years
    }.merge!(options)
    full_attrs[:pic_key] ||= 'FqBarADTwYkTW2EFVaA43PW_0rSu'

    activity = Activity.where(attrs).first || Activity.create!(attrs.merge!(full_attrs))

    attrs = {
      site_id: id,
        activity_id: activity.id
    }

    Greet.where(attrs).first || Greet.create!(attrs)
    activity
  end

  def create_life
    attrs = { website_type: Website::MICRO_LIFE, site_id: id }
    life = Website.where(attrs).first_or_create(name: '微生活')

    now = Time.now
    attrs = {
      site_id: id,
      activity_type_id: ActivityType::LIFE
    }
    full_attrs = {
      activityable_id: life.id,
      activityable_type: 'Website',
      status:   Activity::SETTED,
      name:     life.name,
      keyword:  life.name,
      description:  life.name,
      pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now,
      start_at: now,
      end_at:   now + 100.years
    }.merge! attrs
    activity = Activity.where(attrs).first || Activity.create!(full_attrs)
    life.update_column(:activity_id, activity.id)
    life
  end

  def create_circle
    attrs = { website_type: Website::MICRO_CIRCLE, site_id: id }
    circle = Website.where(attrs).first_or_create(name: '微商圈')

    now = Time.now
    attrs = {
      site_id: id,
      activity_type_id: ActivityType::CIRCLE
    }
    full_attrs = {
      activityable_id: circle.id,
      activityable_type: 'Website',
      status:   Activity::SETTED,
      name:     circle.name,
      keyword:  circle.name,
      description:  circle.name,
      pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now,
      start_at: now,
      end_at:   now + 100.years
    }.merge! attrs
    activity = Activity.where(attrs).first || Activity.create!(full_attrs)
    circle.update_column(:activity_id, activity.id)
    circle
  end

  def create_hospital
    attrs = {site_id: id}

    hospital = Hospital.where(attrs).first_or_create( name: '微医疗' )

    now = Time.now
    attrs = {
      site_id: id,
      activity_type_id: ActivityType::HOSPITAL
    }
    full_attrs = {
      activityable_id: hospital.id,
      activityable_type: 'Hospital',
      status:   Activity::SETTED,
      name:     hospital.name,
      keyword:  hospital.name,
      description:  hospital.name,
      pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
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
      HospitalJobTitle.create!(name: job_title , hospital_id: hospital.id, description: job_title, site_id: full_attrs[:site_id])
    end
  end

  def create_shop
    attrs = { site_id: id }

    ec_shop = EcShop.where(attrs).first_or_create(name: '微电商')

    now = Time.now
    attrs = {
      site_id: id,
        activity_type_id: ActivityType::EC
    }
    full_attrs = {
        activityable_id: ec_shop.id,
        activityable_type: 'EcShop',
        status:   Activity::SETTED,
        name:     ec_shop.name,
        keyword:  ec_shop.name,
        description:  ec_shop.name,
        pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    ec_shop
  end

  def create_booking
    attrs = { site_id: id }

    booking = Booking.where(attrs).first_or_create(name: '微服务')

    now = Time.now
    attrs = {
      site_id: id,
        activity_type_id: ActivityType::BOOKING
    }
    full_attrs = {
        activityable_id: booking.id,
        activityable_type: 'Booking',
        status:   Activity::SETTED,
        name:     booking.name,
        keyword:  booking.name,
        description:  booking.name,
        pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    booking
  end

  def create_group
    attrs = { site_id: id }

    group = Group.where(attrs).first_or_create( name: '团购' )

    now = Time.now
    attrs = {
      site_id: id,
      activity_type_id: ActivityType::GROUP
    }
    full_attrs = {
        activityable_id: group.id,
        activityable_type: 'Group',
        status:   Activity::SETTED,
        name:     group.name,
        keyword:  '支付版团购',
        description:  group.name,
        pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
        ready_at: now,
        start_at: now,
        end_at:   now + 100.years
    }.merge! attrs
    Activity.where(attrs).first || Activity.create!(full_attrs)

    group
  end

  def create_broche
    attrs = { site_id: id }

    broche = Broche.where(attrs).first_or_create( name: '微楼书' )

    now = Time.now
    attrs = {
      site_id: id,
      activity_type_id: ActivityType::BROCHE
    }
    full_attrs = {
        activityable_id: broche.id,
        activityable_type: 'Broche',
        status:   Activity::SETTED,
        name:     broche.name,
        keyword:  broche.name,
        description:  broche.name,
        pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
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

  def create_activity_for(activity_type_id, status, name, keyword, extend_attrs = {})
    attrs, full_attrs = initiate_activity_for(activity_type_id, status, name, keyword, extend_attrs)

    Activity.where(attrs).first || Activity.create!(full_attrs)
  end

  def initiate_activity_for(activity_type_id, status, name, keyword, extend_attrs = {})
    now = Time.now
    default_attrs = {
      site_id: id,
      activity_type_id: activity_type_id
    }
    full_attrs = {
      status:   status,
      name:     name,
      keyword:  keyword,
      # pic_key: Concerns::ActivityQiniuPicKeys.default_site_pic_qiniu_key,
      ready_at: now+1.seconds,
      start_at: now+1.seconds,
      end_at:   now + 100.years
    }
    full_attrs.merge!(default_attrs)
    full_attrs.merge!(extend_attrs) if extend_attrs.present?

    [default_attrs, full_attrs]
  end

end
