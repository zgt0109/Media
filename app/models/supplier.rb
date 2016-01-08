class Supplier < ActiveRecord::Base
  include SupplierPermissions
  include Concerns::Brokerages
  include Concerns::RedPackets
  has_secure_password

  SYSTEM_PAYMENTS = %w[WeixinPaySetting WxpaySetting TenpaySetting AlipaySetting]

  store :metadata, accessors: [:auth_tel]

  attr_accessor :current_password

  validates :status, presence: true
  validates :nickname, presence: true, uniqueness: { case_sensitive: false }, on: :create
  # validates_length_of :invitation_code, :minimum => 0, :maximum => 15, :allow_blank => true

  validates :company_name, presence: true, on: :create, if: :is_reg_web?
  validates :email, email: true, presence: true, uniqueness: {case_sensitive: false}, on: :create, if: :is_reg_web?
  validates :tel, presence: true, uniqueness: {case_sensitive: false}

  # validates :company_name, presence: true, uniqueness: { case_sensitive: false }, if: :is_reg_web?

  # uniqueness: { message: '您输入的邮箱已经被注册', case_sensitive: false }
  # validates :website, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }
  # validates :mobile, format: { with: /^\d{11}$/, message: '手机格式不正确' }

  validates :password, presence: { message: '不能为空', on: :create }, length: { within: 6..20, too_short: '太短了，最少6位', too_long: "太长了，最多20位" }, allow_blank: true
  validates_confirmation_of :password,
                              message: '确认不一致'

  enum_attr :supplier_industry_id, in: SupplierIndustry::ENUM_ID_OPTIONS

  enum_attr :supplier_product_id, :in => [
    ['product0', 10000, '免费版'],
    ['product1', 10001, '商务版'],
    ['product2', 10002, '加强版'],
    ['product3', 10003, '专业版'],
    ['product4', 10004, '行业版'],
    ['product5', 10005, '门户版'],
    ['product6', 10006, 'V领先版'],
    ['product7', 10007, 'V行业版'],
    ['product8', 10008, 'V门户版'],
  ]

  enum_attr :product_line_type, :in => [
    ['winwemedia_line', 1, 'V系列'],
    ['wgift_line', 2, "商站"]
  ]

  enum_attr :account_type, :in => [
    ['normal_account', 1, '正式帐号'],
    ['test_account',   2, '测试帐号'],
    ['trial_account',  3, '试用帐号'],
    ['free_account',  5, '免费帐号'],
    ['bqq_account',  4, '营销QQ帐号'],
  ]

  enum_attr :is_gift, :in => [
    ['not_gift', false, '否'],
    ['gift', true, '是'],
  ]

  enum_attr :status, :in => [
    ['pending', 0, '待审核'],
    ['active',  1, '正常'],
    ['froze',  -1, '已冻结']
  ]

  enum_attr :show_introduce, :in => [
    # ['need', 0, '需要显示'],
    # ['know', 1, '知道了'],
    # ['no',   2, '不再提示'],
    ['task0', 0, '未开始新手任务'],
    ['task1', 1, '已完成新手任务1'],
    ['task2', 2, '已完成新手任务2'],
    ['task3', 3, '已完成新手任务3'],
    ['task4', 4, '已完成新手任务4'],
  ]

  enum_attr :source_type, :in => [
    ['search_engine', 1, '搜索引擎'],
    ['weibo', 2, '微博'],
    ['weixin', 3, '微信'],
    ['internet_news', 4, '网络新闻媒体'],
    ['blog_bbs', 5, '博客空间论坛'],
    ['friends',6, '朋友介绍'],
    ['dayin_seller',7, '微枚迪销售员'],
    ['winwemedia_agent',8, '微枚迪代理商'],
    ['other_source',9,'其它']
  ]

  enum_attr :upgrade_type, :in => [
    ['trial_change_normal', 1, "试用转正式"],
    ['free_change_normal', 2, "免费转正式"],
    ['agent_buy_normal', 3, "代理购买"],
    ['renew_account', 4, "续费账号"],
    ['website_register_trial', 5, "官网注册试用"],
    ['agent_register_trial', 6, "代理商注册试用"],
    ['normal_change_free', 7, "付费到期转免"],
    ['trial_change_free', 8, "试用转免"],
    ['upgrade_account', 9, "升级账号"],
    ['register_free', 10, "免费帐号"]
  ]

  belongs_to :supplier_category
  belongs_to  :supplier_industry
  belongs_to  :agent
  belongs_to  :supplier_footer
  has_many  :supplier_footers
  has_one  :wx_mp_user, inverse_of: :supplier
  has_many  :wx_users, inverse_of: :supplier
  has_many  :wx_requests
  has_many  :piwik_sites
  has_one  :supplier_account
  has_one  :baidu_app, foreign_key: 'custom_id'
  has_one  :house
  has_one  :car_shop
  has_one  :hotel
  has_one  :website, conditions: { website_type: Website::MICRO_SITE }
  has_one  :life, class_name: 'Website', conditions: { website_type: Website::MICRO_LIFE }
  has_one  :circle, class_name: 'Website', conditions: { website_type: Website::MICRO_CIRCLE }
  has_one  :vip_card
  has_one  :supplier_password
  has_one  :trip#微旅游
  has_many  :trip_ticket_categories
  has_one  :share_photo_setting
  has_one  :wx_plot
  has_one :activity_wx_plot_bulletin, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_BULLETIN }
  has_one :activity_wx_plot_repair, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_REPAIR }
  has_one :activity_wx_plot_complain, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_COMPLAIN }
  has_one :activity_wx_plot_owner, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_OWNER }
  has_one :activity_wx_plot_life, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_LIFE }
  has_one :activity_wx_plot_telephone, class_name: 'Activity', conditions: { activity_type_id: ActivityType::PLOT_TELEPHONE }
  has_many :wbbs_communities
  has_many :reservation_orders
  has_many :wbbs_topics
  has_many :sms_expenses
  has_many :sms_orders
  has_many :supplier_print_settings
  has_many :share_photos
  has_many :vip_groups, through: :vip_card
  has_many :vip_grades, through: :vip_card
  has_many :vip_message_plans, through: :vip_card
  has_many :vip_users, inverse_of: :supplier
  has_many :vip_privileges, through: :vip_card
  has_many :wx_menus
  has_many :materials
  has_many :supplier_withdraws
  has_many :supplier_transactions
  has_many :activities
  has_many :activity_consumes
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
  has_many :assistants_suppliers
  has_many :assistants, through: :assistants_suppliers
  has_many :point_gifts, dependent: :destroy
  has_many :point_gift_exchanges, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :point_types, dependent: :destroy
  has_many :vip_user_messages, dependent: :destroy
  has_many :leaving_messages, dependent: :destroy
  has_many :leaved_messages,  dependent: :destroy, class_name: 'LeavingMessage', as: :replier
  has_many :supplier_apps, dependent: :destroy
  has_many :supplier_industries, through: :supplier_apps
  has_many :supplier_prints
  has_many :assistants_suppliers
  has_many :wifi_clients
  has_many :supplier_print_clients, through: :supplier_prints
  has_many :share_photo_comments
  has_many :share_photo_likes
  has_many :share_photos
  has_one  :share_photo_setting
  has_many :payment_settings

  has_many :car_bespeaks, dependent: :destroy
  has_many :car_sellers, dependent: :destroy
  has_many :car_brands, dependent: :destroy
  has_one :car_brand, dependent: :destroy
  has_many :car_catenas, dependent: :destroy
  has_many :car_activity_notices, dependent: :destroy
  has_many :vip_user_transactions, dependent: :destroy
  has_many :wx_walls, dependent: :destroy
  has_many :channel_types, dependent: :destroy
  has_many :channel_qrcodes, dependent: :destroy
  has_many :qrcode_logs, dependent: :destroy
  has_many :qrcode_users, dependent: :destroy
  has_many :vip_packages
  has_many :vip_package_item_consumes
  has_many :vip_packages_vip_users
  has_many :vip_external_http_apis
  has_many :vip_importings
  has_many :wx_shakes
  has_many :wx_shake_rounds
  has_many :wx_shake_prizes
  has_many :wx_shake_users
  has_many :system_messages, order: 'created_at DESC'
  has_many :system_message_settings
  has_one  :broche

  has_one :supplier_app_info, as: :userable
  has_many :igetui_messages, as: :userable

  # wmall
  has_one :mall, class_name: "Wmall::Mall"
  #wmall_klasses = ["SlidePicture", "Activity", "Shop", "Product"]
  #wmall_klasses.each do |it|
  #  has_many ("Wmall::"+it).underscore.gsub("/","_").pluralize.to_sym, class_name: "Wmall::#{it}"
  #end

  has_many :staffs, class_name: 'Kf::Staff'
  has_one :wshop, class_name: 'Activity', conditions: { activity_type_id: ActivityType::WSHOP }
  belongs_to :city
  accepts_nested_attributes_for :car_activity_notices, :wx_plot, :system_message_settings

  has_many :payments#, as: :customer

  has_many :panoramagrams
  has_many :cards, class_name: "Wx::Card"

  has_many :red_packets, class_name: 'RedPacket::RedPacket'

  before_create :add_default_attrs

  after_create :add_addition_attrs#, :get_piwik_site_id

  def self.current
    Thread.current[:supplier]
  end

  def self.current=(supplier)
    Thread.current[:supplier] = supplier
  end

  def self.authenticated(nickname, password)
    #where("lower(nickname) = ?", nickname.to_s.downcase).first.try(:authenticate, password)
    where("lower(nickname) LIKE ?", nickname.to_s.downcase).first.try(:authenticate, password)
  end

  # def self.authorize(account)
  #   where("lower(nickname) = :value OR lower(email) = :value", value: account.downcase).first
  # end
  #
  # def self.authenticated(account, password)
  #   # find_by_email(email).try(:authenticate, password)
  #   user = authorize(account)
  #   user.try(:authenticate, password)
  # end

  def wx_qr_code_url
    qiniu_image_url(wx_qr_code) if wx_qr_code.present?
  end

  # 商户发送短信 supplier.send_message("13795288852", "Hello World", "电商")
  # 参数 operation in (电商,餐饮, 酒店)
  def send_message(mobiles, content, operation, is_free = false)
    @errors = []
    @errors << "手机号码不能为空" if mobiles.blank?

    phones = mobiles.split(',').map(&:to_s).map{|m| m.gsub(' ', '')}.compact.uniq
    unless is_free
      @errors << "商户未开启短信通知服务" unless self.allow_expense_sms
    end

    phones.map{|m| @errors << "手机号码格式不正确" unless m.to_s =~ /^\d+$/ }
    @errors << "短信内容不能为空" if content.blank?

    if @errors.blank?
      if is_free
        mass_send_message(phones, content)
      elsif self.free_sms > 0
        message_id = mass_send_message(phones, content)
        send_success = message_id > 1 || message_id < -10000000
        sms_status = send_success ? 1 : message_id
        self.update_attribute(:free_sms, self.free_sms - phones.count) if send_success
      elsif self.pay_sms > 0
        message_id = mass_send_message(phones, content)
        send_success = message_id > 1 || message_id < -10000000
        sms_status = send_success ? 1 : message_id
        self.update_attribute(:pay_sms, self.pay_sms - phones.count) if send_success
      else
        @errors << "商户 supplier_id #{self.id} 短信套餐余额不足"
        sms_status = -99
      end
      operation_id = SmsExpense.get_operation_id_by_operation_name(operation)
      phones.each{|phone| SmsExpense.create(date: Date.today, supplier_id: self.id, phone: phone, content: content, operation_id: operation_id, status: sms_status)} if !is_free
    end
    {errors: @errors, message_id: message_id}
  rescue => e
    Rails.logger.info "supplier send_message is error: #{e}"
    e.backtrace.each { |error_msg| Rails.logger.info error_msg }
    {errors: ["发送短信出错：#{e.message}"], message_id: 0}
  end

  def send_system_message(options = {}, smm = nil)
    smm = SystemMessageModule.where(module_id: options[:module_id]).first unless smm
    sms = SystemMessageSetting.where(supplier_id: options[:supplier_id], system_message_module_id: smm.id).first_or_initialize(supplier_id: options[:supplier_id], system_message_module_id: smm.id)
    if sms.is_open
      sms.system_messages << SystemMessage.new(supplier_id: options[:supplier_id], content: options[:content], system_message_module_id: smm.id)
      sms.save!
    else
      sms.view_remind_music
    end
  end

  def update_all_system_messages
    if system_messages.unread.update_all(is_read: true) > 0
      uri = URI.parse("http://#{FAYE_HOST}/faye")
      Net::HTTP.post_form(uri, message: {channel: "/system_messages/change/#{id}", data: {operate: 'delete_all'}}.to_json)
    end
  end

  def has_industry_for?(industry_id)
    return true if test_account? || is_gift? || industry_wmall? || industry_shangzhan?

    (supplier_industry_ids + [supplier_industry_id]).compact.flatten.uniq.include?(industry_id)
  end

  def supplier_privileges
    SupplierPrivilege.where(id: privileges.to_s.split(','))
  end

  def has_privilege_for?(id)
    return true if test_account? || is_gift? || industry_wmall? || industry_shangzhan?

    ( privileges.to_s.split(',') + custom_privileges.to_s.split(',') ).uniq.include?(id.to_s)
  end

  def has_privilege_menu_for?(menu_id)
    supplier_privileges.pluck(:menu_id).uniq.include?(menu_id)
  end

  def bqq_website_product
    privilege_ids = privileges.to_s.split(',')
    if privilege_ids.include?('2101')
      WebsiteTemplate::BQQ_WEBSITE_PRODUCTS[2101]
    elsif privilege_ids.include?('2102')
      WebsiteTemplate::BQQ_WEBSITE_PRODUCTS[2102]
    else
      WebsiteTemplate::BQQ_WEBSITE_PRODUCTS[2103]
    end
  end

  def find_or_generate_auth_token(encrypt = true)
    update_attributes(auth_token: SecureRandom.urlsafe_base64(60)) unless auth_token.present?
    encrypt ? Des.encrypt(self.auth_token) : self.auth_token
  end

  def uid
    @uid ||= self.wx_mp_user.try(:openid)
  end

  def wx_logs_by_date(date)
    WxLog.by_date(date).by_uid(self.uid)
  end

  def app_footer
    SupplierFooter.find_by_id(self.supplier_footer_id) || SupplierFooter.default_footer
  end

  def update_sign_in_attrs_with(sign_in_ip)
    update_attributes(
      sign_in_count: sign_in_count.next,
      last_sign_in_at: current_sign_in_at,
      last_sign_in_ip: current_sign_in_ip,
      current_sign_in_at: Time.now,
      current_sign_in_ip: sign_in_ip
    )
  end

  def update_show_introduce(ret = nil)
    if ret
      self.update_column("show_introduce", ret)
    elsif self.show_introduce == 1
      # supplier.show_introduce == 0 # 下次再说 => 登录 = 还要提醒
      self.update_column("show_introduce", 0)
    end
  end

  def active!
    update_attributes!(status: ACTIVE)
  end

  def froze!
    update_attributes!(status: FROZE)
  end

  def open_sms!
    update_attributes!(allow_expense_sms: true)
  end

  def close_sms!
    update_attributes!(allow_expense_sms: false)
  end

  def can_change_industry?
    test_account? or is_gift?
  end

  def expired?
    expired_at.nil? || expired_at < Time.now
  end

  def can_pay?
    payment_settings.present?
  end

  def can_show_introduce?
    trial_account?# || free_account?
  end

  def can_recharge?
    (enabled_payment_setting_types & SYSTEM_PAYMENTS).present?
  end

  def need_auth_tel?
    auth_tel.to_i != 1 && agent_id != 10656
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
    memkey = "Supplier_piwik_entry_pages_labels_#{self.piwik_site_id}"
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
    memkey = "Supplier_piwik_entry_pages_urls_#{idSubtable}_#{self.piwik_site_id}"
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
    memkey = "Supplier_hour_piwik_data_#{date}_#{self.piwik_site_id}"
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
    memkey = "Supplier_daily_piwik_data_#{date}_#{self.piwik_site_id}"
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
    memkey = "Supplier_daily_piwik_data_#{date}_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      piwik_sites.where(date: date).first
    end
  rescue => error
    nil
  end

  def bounce_rate
    memkey = "Supplier_bounce_rate_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      _bounce_rates = PiwikSite.where(:supplier_id => self.id).limit(30).pluck(:bounce_rate)
      _bounce_rates.count.zero? ? 0.0 : (_bounce_rates.sum / _bounce_rates.count).round(2) rescue 0.0
    end
  end

  def avg_time_on_site
    memkey = "Supplier_avg_time_on_site_#{self.piwik_site_id}"
    Rcache.fetch(memkey, 15.minutes) do
      _avg_time_on_sites = PiwikSite.where(:supplier_id => self.id).limit(30).pluck(:avg_time_on_site)
      _avg_time_on_sites.count.zero? ? 0.0 : (_avg_time_on_sites.sum / _avg_time_on_sites.count).round(2) rescue 0.0
    end
  end

  def save_daily_piwik_data(date)
    daily_data = daily_piwik_data(date)
    if daily_data.present? && daily_data["result"] != "error"
      piwik = PiwikSite.where(:date => date, :supplier_id => self.id).first_or_create
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

  def supplier_password_correct?( password )
    password.present? && password == supplier_password.try(:password_digest)
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
      Supplier.update_all(executes.join(","), ["id = ?", self.id])
    end
  rescue Exception => e
    Rails.logger.info "Supplier.get_piwik_site_id ERROR: #{e}"
  end

  def add_default_attrs
    if self.is_reg_web #如果是前台自助申请试用的
      privileges = [
        1000, 1001, 1002, 1003,
        1010, 1011, 1012, 1013, 1014, 1015,
        1020, 1021, 1022, 1023,
        1030, 1031, 1032,
        1040, 1041, 1042, 1043,
        1050,
        1, 2,
        5000, 4, 5, 8, 25, 28, 33, 62, 64, 67,
        6000, 10, 12, 15, 19, 24, 37, 49, 63,
        11, 14, 30, 38, 55,
        10007,
      ]

      self.account_type = 3
      self.status = 1
      self.service_cycle = 1
      self.supplier_industry_id = 10000
      self.supplier_product_id = 10006
      self.privileges = privileges.join(',')
      self.expired_at = (created_at || Time.now) + 30.days #试用期30天
    end
  end

  def add_addition_attrs
    if is_reg_web? #如果是前台自助申请试用的
      #创建一条线索
      supplier_apply = SupplierApply.new(apply_type: SupplierApply::FREE)
      supplier_apply.source_type = 10 #来源类型是网页注册
      supplier_apply.name = company_name
      supplier_apply.tel = tel
      supplier_apply.contact = contact
      supplier_apply.email = email
      # supplier_apply.invitation_code = invitation_code
      # supplier_apply.website = self.website
      supplier_apply.apply_source = apply_source
      supplier_apply.qq = qq
      supplier_apply.province_id = province_id
      supplier_apply.city_id = city_id
      supplier_apply.district_id = district_id
      supplier_apply.address = address
      # supplier_apply.intro
      supplier_apply.save(validate: false)

      update_attributes(supplier_apply_id: supplier_apply.try(:id))
    else
      update_attributes(supplier_product_id: 10006) if [10001, 10003].include?(supplier_product_id)
    end
  end

  def update_expired_privileges
    return if free_account? or bqq_account?
    # return unless expired?

    supplier_apps.clear

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
      supplier_product_id: 10000,
      supplier_industry_id: 1000,
      is_gift: false,
      account_type: 5,
      upgrade_type: normal_account? ? NORMAL_CHANGE_FREE : TRIAL_CHANGE_FREE,
      upgrade_at: Time.now
    }
    update_attributes(attrs)
  end

  def update_privileges
    return if bqq_account?

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
    elsif supplier_product_id == 10006
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
    elsif supplier_product_id == 12000
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

    if supplier_product_id == 10006
      new_custom_privileges = supplier_industry_ids + [supplier_industry_id] + custom_privileges.to_s.split(',').map(&:to_i)
    else
      new_custom_privileges = supplier_industry_ids + [supplier_industry_id]
    end

    update_attributes(privileges: new_privileges.uniq.join(','), custom_privileges: new_custom_privileges.uniq.join(','))
  end

  def buy_sms_totality
    self.sms_orders.buy.where(status: [SmsOrder::SUCCEED, SmsOrder::F_DELETE]).collect(&:plan_sms).sum
  end

  def giv_sms_totality
    self.sms_orders.giv.collect(&:plan_sms).sum
  end

  def usable_sms
    self.pay_sms.to_i + self.free_sms.to_i
  end

  def sms_expenses_count(date, operation_id = nil)
    condtions = {date: date, status: 1}
    condtions.merge!(operation_id: operation_id) if  operation_id
    self.sms_expenses.where(condtions).count
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    SupplierMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while Supplier.exists?(column => self[column])
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

  # supplier.delay.init_website_data
  def init_website_data
    if Rails.env.staging? || Rails.env.production?
      supplier_id = 73290
    else
      supplier_id = 35067
    end
    from_user = Supplier.where(id: supplier_id).first || Supplier.first
    return puts "user not exists" unless from_user

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

  private

  def do_send_message(phone, content)
    sms_service = SmsService.new
    sms_service.singleSend(phone, content)
    # result =  rand  > 0.3 && 101812252025653392 || -4

    # 短信发送失败，添加错误信息
    @errors << sms_service.error_message if sms_service.error?
    sms_service.result
  end

  def mass_send_message(phones, content)
    sms_service = SmsService.new
    sms_service.batchSend(phones, content)
    # 短信发送失败，添加错误信息
    @errors << sms_service.error_message if sms_service.error?
    sms_service.result
  end

end
