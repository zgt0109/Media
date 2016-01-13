class ShopBranch < ActiveRecord::Base
  EARTH_RADIUS = 6378137.0 #地球半径
  PI = Math::PI

  has_secure_password validations: false
  # attr_accessible :address, :name, :description, :end_time, :hall_count, :loge_count, :province, :start_time, :status, :tel
  validates :password, presence: true, if: :no_password_and_can_validate?
  validates :name, :address, presence: true
  validates :open_hall_count, :open_loge_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # validates_length_of :book_table_rule,  :maximum => 30, :allow_blank => true
  # validates :name, :uniqueness => {:scope => [:shop_id, :status]}
  validates :name, uniqueness: {:scope => [:shop_id, :status], message: '不能重复', case_sensitive: false }, presence: true, :if => :valStatus?
  validates :tel, presence: true, format: { with: /^[0-9_\-]*$/, message: '电话号码只能包含数字,-和_' }

  belongs_to :site
  belongs_to :shop
  belongs_to :province
  belongs_to :city
  belongs_to :district
  belongs_to :shop_menu
  has_many :shop_table_orders, dependent: :destroy
  has_many :shop_orders, dependent: :destroy
  has_many :shop_categories, dependent: :destroy
  has_many :shop_products, dependent: :destroy
  has_many :shop_images, dependent: :destroy
  has_many :shop_table_settings, dependent: :destroy
  has_many :vip_user_transactions
  has_and_belongs_to_many :point_gifts
  has_and_belongs_to_many :coupons
  has_and_belongs_to_many :vip_packages

  has_many :point_gift_exchanges, through: :point_gifts
  has_many :exchanging_counsumes, through: :point_gift_exchanges, source: :consume
  has_many :consumes, as: :applicable
  has_many :activity_consumes
  has_many :shop_branch_print_templates, dependent: :destroy
  has_many :vip_packages_vip_users, dependent: :destroy
  has_many :vip_package_item_consumes, dependent: :destroy

  has_many :book_rules
  # has_many :book_time_ranges, through: book_rules
  has_many :qiniu_pictures, as: :target
  has_one :sub_account, as: :user, dependent: :destroy
  store :metadata, accessors: [:thumbnail]


  enum_attr :status, :in => [
    ['used', 1, '使用中'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :print_type, :in => [
    ['gprs', 1, 'gprs'],
    ['pc', 2, '直连']
    # ['auto', 3, '自动打印']
  ]

  accepts_nested_attributes_for :shop_categories, reject_if: proc { |attributes| attributes['name'].blank? }

  before_create :add_default_attrs
  after_create :associate_point_gifts
  after_update :update_table
  after_save :save_sub_account

  scope :visitable, :include => [:shop_products], :conditions => "shop_products.id IS NOT NULL and shop_branches.status = 1"
  scope :any_shops, -> (ids) { where(id: ids) if ids.present? }

  def vip_user_transactions_pay_json
    vip_user_transactions.by_pay.recent.includes(:vip_user).map do |transaction|
      [ transaction.created_at.to_s, transaction.vip_user.try(:user_no), transaction.vip_user.try(:name), transaction.vip_user.try(:mobile), transaction.direction_type_name, transaction.amount_source_name, transaction.amount, (transaction.payment_type_name if transaction.pay_down?), transaction.intro ]
    end
  end

  def available_vip_packages
    site.vip_card.vip_packages.where("shop_branch_limited = 0 OR id IN (select vip_package_id from shop_branches_vip_packages where shop_branch_id=#{id})")
  end

  def no_password_and_can_validate?
    password_digest.blank? && can_validate?
  end

  def valStatus?
    status != -1
  end

  def start_time_to_s
    [start_time.try(:hour).to_s.rjust(2, '0'), start_time.try(:min).to_s.rjust(2, '0')].join(':')
  end

  def end_time_to_s
    [end_time.try(:hour).to_s.rjust(2, '0'), end_time.try(:min).to_s.rjust(2, '0')].join(':')
  end

  def business_hours
    "#{start_time_to_s} - #{end_time_to_s}"
  end

  def delete!
    update_attributes(status: DELETED)
  end

  def ditu_address
    _default_province = [ 1, 2, 9, 22 ].include?(province_id) ? nil : province.try(:name)
    [_default_province, city.try(:name), district.try(:name), address].compact.join
  end

  def book_dinner_template
    shop_branch_print_templates.book_dinner.first || create_template(1)
  end

  def take_out_template
    shop_branch_print_templates.take_out.first || create_template(2)
  end

  def book_table_template
    shop_branch_print_templates.book_table.first || create_template(3)
  end

  def book_dinner_rule
    rule = self.book_rules.where(:rule_type => 1).first
    rule = create_rule 1 unless rule
    return rule
  end

  def take_out_rule
    rule = self.book_rules.where(:rule_type => 3).first
    rule = create_rule 3 unless rule
    return rule
  end 

  def book_table_rule
    rule = self.book_rules.where(:rule_type => 2).first
    rule = create_rule 2 unless rule
    return rule
  end

  def create_rule(rule_type)
    self.book_rules.create(rule_type: rule_type, book_phone: self.tel)
  end

  def create_template(template_type)
    t = self.shop_branch_print_templates.create(template_type:    template_type,
                                                title:            '欢迎光临',
                                                is_print_kitchen: true,
                                                is_open:          true,
                                                print_type:       1,
                                                is_auto_print:    true
    )
    t.thermal_printers.create(no: self.id)
    t
  end

  def get_templates shop_order
    if shop_order.book_dinner?
      return self.book_dinner_template
    end
    if shop_order.take_out?
      return self.take_out_template
    end
  end

  def get_shop_branch_location
    params = { address: self.ditu_address, output: 'json', ak: '9c72e3ee80443243eb9d61bebeed1735'}
    result = RestClient.get('http://api.map.baidu.com/geocoder/v2/', params: params)
    data = JSON(result)
    data['result']['location']
  rescue
    {}
  end

  def thumbnail_url
    qiniu_image_url(thumbnail)
  end

  def self.some_shop_branches(site,wx_user)
    if wx_user
      site.shop_branches.used.sort do |s1,s2|
        s1.distance_to(wx_user) - s2.distance_to(wx_user)
      end.take(9)
    else
      site.shop_branches.used.limit(9)
    end
  end

  def self.search_some_shop_branches(search,wx_user)
    if wx_user
      shop_branches = search.relation.sort do |s1,s2|
        s1.distance_to(wx_user) - s2.distance_to(wx_user)
      end
    else
      search.relation
    end
  end

  def pic_url
    thumbnail_url || '/assets/micro_stores/small_default.png'
  end

  def self.get_rad(d)
    return d.to_f*PI/180.0
  end

  def self.get_great_circle_distance(lat1,lng1,lat2,lng2)
    lat1,lng1,lat2,lng2 = [lat1,lng1,lat2,lng2].map(&:to_f)
    radLat1 = ShopBranch.get_rad(lat1)
    radLat2 = ShopBranch.get_rad(lat2)
    a = radLat1 - radLat2
    b = ShopBranch.get_rad(lng1) - ShopBranch.get_rad(lng2)
    s = 2*Math.asin(Math.sqrt(Math.sin(a/2)**2 + Math.cos(radLat1)*Math.cos(radLat2)*Math.sin(b/2)**2))
    s = s*EARTH_RADIUS
    return (s/1000).round(2)
  end

  def distance_to(wx_user)
    return 10**20 if [location_x, location_y, wx_user.location_y, wx_user.location_x].map(&:presence).compact.size < 4
    ShopBranch.get_great_circle_distance(location_x, location_y, wx_user.location_y, wx_user.location_x)
  end

  def human_distance_to(wx_user)
    return '' unless wx_user
    distance = distance_to(wx_user)
    if distance > 1000000000
      ''
    else
      wx_user.location_updated_at + 10.minutes > Time.now ? "#{distance}km" : ''
    end
  end

  private

  def add_default_attrs
    return unless self.shop

    self.site_id = self.shop.site_id
    self.start_time = '00:00:00' unless self.start_time
    self.end_time = '23:59:00' unless self.end_time
  end

  def update_table
    if open_loge_count_changed? or open_hall_count_changed?
      table = shop_table_settings.where(date: open_at.to_date).first
      if table
        table.update_attributes(open_hall_count: open_hall_count, open_loge_count: open_loge_count)
      else
        shop_table_settings.create(date: open_at.to_date, open_hall_count: open_hall_count, open_loge_count: open_loge_count)
      end
    end

    if self.is_auto_print
      self.update_column('print_type', 1)
    end
    if self.pc?
      self.update_column('is_auto_print', false)
    end
  rescue
  end

  def associate_point_gifts
    self.point_gift_ids = site.point_gifts.shop_branch_unlimited.pluck(:id)
  end

  def save_sub_account
    sub_account = self.sub_account || build_sub_account
    sub_account.username = name
    sub_account.password_digest = password_digest
    sub_account.save(validate: false)
  end

end
