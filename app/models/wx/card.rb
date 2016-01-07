class Wx::Card < ActiveRecord::Base
  include WxCardApi
  serialize :location_id_list, Array
  belongs_to :supplier
  has_many :consumes, as: :consumable

  scope :latest, -> { order('id DESC') }
  scope :show, -> { where("status != ?", -1)}
  scope :unexpired, -> { where("date_info_end_at is null OR date_info_end_at > ?", Date.today)}

  acts_as_enum :card_type, in: [
    %w(general_coupon GENERAL_COUPON 通用券),
    %w(groupon        GROUPON        团购券),
    %w(discount       DISCOUNT       折扣券),
    %w(gift           GIFT           礼品券),
    %w(cash           CASH           代金券),
    %w(member_card    MEMBER_CARD    会员卡),
    %w(scenic_ticket  SCENIC_TICKET  门票),
    %w(movie_ticket   MOVIE_TICKET   电影票),
    %w(boarding_pass  BOARDING_PASS  飞机票),
    %w(lucky_money    LUCKY_MONEY    红包),
  ]
  
  acts_as_enum :code_type, in: [
    %w(code_type_text    CODE_TYPE_TEXT    文本),
    %w(code_type_barcode CODE_TYPE_BARCODE 一维码),
    %w(code_type_qrcode  CODE_TYPE_QRCODE  二维码),
  ]
  
  acts_as_enum :date_info_type, in: [
    ['fixed_time', 1, '固定日期区间'],
    ['fixed_term', 2, '固定时长'] # 自领取后按天算
  ]

  acts_as_enum :url_name_type, in: [
    %w[url_name_type_take_away           URL_NAME_TYPE_TAKE_AWAY           外卖],
    %w[url_name_type_reservation         URL_NAME_TYPE_RESERVATION         在线预订],
    %w[url_name_type_use_immediately     URL_NAME_TYPE_USE_IMMEDIATELY     立即使用],
    %w[url_name_type_appointment         URL_NAME_TYPE_APPOINTMENT         在线预约],
    %w[url_name_type_exchange            URL_NAME_TYPE_EXCHANGE            在线兑换],
    %w[url_name_type_vehicle_information URL_NAME_TYPE_VEHICLE_INFORMATION 车辆信息],
  ]

  acts_as_enum :status, in: [
    ['card_not_pass_check', 0, '未审核'],
    ['card_pass_check',     1, '已审核'],
    ['deleted',            -1, '已删除']
  ]

  validates :card_type, presence: true, inclusion: CARD_TYPES.keys
  validates :code_type, presence: true, inclusion: CODE_TYPES.keys

  validates :brand_name, presence: true, length: { maximum: 12 } # 商户名字,字数上限为 12 个汉 字。(填写直接提供服务的商户 名,第三方商户名填写在 source 字段)
  validates :title, presence: true, length: { maximum: 9 } # 券名,字数上限为 9 个汉字。(建 议涵盖卡券属性、服务及金额)
  validates :sub_title, length: { maximum: 18 } # 券名的副标题,字数上限为 18 个汉字。
  COLORS = %w(Color010 Color020 Color030 Color040 Color050 Color060 Color070 Color080 Color090 Color100 Color101)
  validates :color, presence: true, inclusion: { in: COLORS } # 按色彩规范标注填写 Color010-Color100
  validates :notice, presence: true, length: { maximum: 9 } # 使用提醒,字数上限为 9 个汉 字。(一句话描述,展示在首页, 示例:请出示二维码核销卡券)
  validates :description, presence: true, length: { maximum: 1000 } # 使用说明。长文本描述,可以分 行,上限为 1000 个汉字。

  validates :date_info_type, presence: true, inclusion: DATE_INFO_TYPES.keys
  validates :date_info_start_at, presence: true, if: :fixed_time?
  validates :date_info_end_at, presence: true, if: :fixed_time?
  validates :date_info_fixed_term, presence: true, if: :fixed_term? # 固定时长专用,表示自领取后多 少天内有效。(单位为天)
  validates :date_info_fixed_begin_term, presence: true, if: :fixed_term? # 固定时长专用,表示自领取后多 少天开始生效。(单位为天)
  validates :sku_quantity, presence: true, numericality: {greater_than: 0} # 固定时长专用,表示自领取后多 少天开始生效。(单位为天)

  validates :url_name_type, inclusion: URL_NAME_TYPES.keys, allow_blank: true # (该权限申请及说明详见 Q&A)与 custom_url 字段共同 使用

  validates :general_coupon_default_detail, presence: true, if: :general_coupon? # 描述文本
  validates :groupon_deal_detail, presence: true, if: :groupon? # 团购券专用,团购详情。
  validates :gift_gift, presence: true, if: :gift? # 礼品券专用,表示礼品名字。
  validates :cash_reduce_cost, presence: true, if: :cash? # 代金券专用,表示减免金额(单位为分)
  validates :discount_discount, presence: true, numericality: {minimum: 0, maximum: 100}, if: :discount? # 折扣券专用,表示打折额度(百分 比)。填 30 就是七折。

  validates :member_card_supply_bonus, presence: true, if: :member_card? # 是否支持积分,填写 true 或 false, 如填写 true,积分相关字段均为必 填。填写 false,积分字段无需填写。 储值字段处理方式相同。
  validates :member_card_supply_balance, presence: true, if: :member_card_supply_bonus? # 是否支持储值,填写 true 或 false。
  validates :member_card_prerogative, presence: true, if: :member_card_supply_bonus? # 特权说明

  validates :from, :to, presence: true, length: {maximum: 18}, if: :boarding_pass? # 航班起点、终点
  validates :flight, presence: true, if: :boarding_pass? # 航班
  validates :air_model, length: {maximum: 8}, allow_blank: true, if: :boarding_pass? # 特权说明
  validates :departure_time, :landing_time, length: {maximum: 17}, allow_blank: true, if: :boarding_pass? # 起飞时间,上限为 17 个汉字。
  validates :service_phone, presence: true # 客服电话

  validate :sku_quantity_greater_than_get_limit

  before_create :card_create

  delegate :wx_mp_user, to: :supplier, allow_nil: true

  def name
    title
  end

  def date_info
    if fixed_time?
      {type: date_info_type, begin_timestamp: date_info_start_at.to_i, end_timestamp: date_info_end_at.to_i}
    else
      {type: date_info_type, fixed_term: date_info_fixed_term, fixed_begin_term: date_info_fixed_begin_term}
    end
  end

  def sku
    {quantity: sku_quantity}
  end

  def card_type_specific_info
    card_type_prefix = %r/^#{card_type.downcase}_/
    card_field_names = Wx::Card.column_names.grep(card_type_prefix)
    card_field_names.each_with_object({}) do |field_name, hash|
      key = field_name.sub(card_type_prefix, '')
      hash[key] = cash? ? (self[field_name]*100) : self[field_name]
    end
  end

  def wx_card_type
    if fixed_time?
      "#{date_info_start_at} - #{date_info_end_at}"
    else
      "领取后，#{date_info_fixed_begin_term == 0 ? '当' : date_info_fixed_begin_term}天生效，有效天数#{date_info_fixed_term}天"
    end
  end

  def basic_card_info(wx_user)
    card_list = []
    hash = {card_id: card_id, card_ext: {}}
    consume = wx_mp_user.consumes.create(wx_user_id: wx_user.id, consumable: self, status: Consume::HIDDEN)
    hash[:card_ext][:code] = consume.code
    hash[:card_ext][:timestamp] = Time.now.to_i.to_s
    hash[:card_ext][:signature] = Digest::SHA1.hexdigest([wx_mp_user.app_secret.to_s, hash[:card_ext][:timestamp], card_id.to_s, consume.code].sort.join)
    hash[:card_ext] = hash[:card_ext].to_json.to_s
    card_list << hash
    card_list
  end

  def title_with_type(wx_user)
    {
      color: (COLORS.index(color).to_i+1),
      title: title, 
      sub_title: sub_title, 
      wx_card_type: wx_card_type,
      basic_card_info: basic_card_info(wx_user).to_json
    }
  end

  def qiniu_logo_url
    qiniu_image_url(logo_url)
  end

  def sku_quantity_greater_than_get_limit
    self.errors.add(:sku_quantity, '不能小于领券限制') if self.sku_quantity && self.get_limit && self.get_limit > self.sku_quantity
  end


end
