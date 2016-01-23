class Consume < ActiveRecord::Base
include HasBarcode

  belongs_to :site
  belongs_to :user
  belongs_to :activity_prize
  belongs_to :consumable, polymorphic: true
  belongs_to :applicable, polymorphic: true
  belongs_to :card, class_name: 'Wx::Card', foreign_key: 'consumable_id', conditions: "consumes.consumable_type = 'Wx::Card'"
  has_one :wx_prize

  before_create :generate_code
  before_create :generate_mobile
  enum_attr :status, in: [
    ['deleted', -1, '已删除'],
    ['unused', 1, '未使用'],
    ['used',   2, '已使用'],
    ['hidden', 3, '已隐藏'],
    ['auto_used',   4, '已自动增加积分'],
  ]

  enum_attr :consumable_type, in: [
    ['point_gift_exchange', 'PointGiftExchange',  '礼品券'],
    ['coupon',              'Coupon',             '优惠券'],
    ['activity',            'Activity',           '活动'],
    ['wx_card',             'Wx::Card',           '微信卡券'],
    ['red_packet',          'RedPacket::Release', '节日礼包']
  ]

  scope :is_consumable, ->(consumable) { where(consumable_id: consumable.id, consumable_type: consumable.class.to_s) }
  scope :is_applicable, ->(applicable) { where(applicable_id: applicable.id, applicable_type: applicable.class.to_s) }
  scope :unexpired, -> { where("expired_at IS NULL OR expired_at >= ?", Time.now) }
  scope :coupon_use_start, -> { joins("join coupons on coupons.id = consumes.consumable_id AND consumes.consumable_type = 'Coupon'").where("coupons.use_start <= ? ", Time.now).where("coupons.use_end > ?", Time.now) }
  scope :recommend, -> { joins("join activities on activities.id = consumes.consumable_id AND consumes.consumable_type = 'Activity'").where("activities.activity_type_id = 70") }
  scope :unfold, -> { joins("join activities on activities.id = consumes.consumable_id AND consumes.consumable_type = 'Activity'").where("activities.activity_type_id = 71") }
  scope :recent, -> { order('id DESC') }
  scope :visible, -> { where("status != 3")}
  scope :today, -> { where("date(consumes.created_at) = ?", Date.today) }
  scope :wx_card_columns, -> { includes(:card).select("date(consumes.created_at) as created_date, count(consumes.*) as total_count, count(if(consumes.status='2',true,null )) as used_count, card.title as title, card.card_type_name as card_type_name").group('created_date') }
  scope :wx_card_consumes, ->(user_id) { where(user_id: user_id, consumable_type: 'Wx::Card') }
  scope :show, -> { where("status != ?", 3)}


  def status_text
    if used? || mobile.present?
      status_name
    else
      '未使用'
    end
  end

  def self.point_gift_exchange_json
    point_gift_exchange.recent.includes(:applicable, :consumable).map.with_index do |consume, i|
      exchange = consume.consumable
      [ i + 1, exchange.point_gift.try(:name), exchange.vip_user.name, exchange.vip_user.mobile, exchange.updated_at.to_s[0..15], consume.applicable.try(:name), consume.code ]
    end
  end

  def use!( applicable=nil, description=nil)
    if activity_prize.try(:point_prize?) # 积分奖需要判断是否是会员
      return false if used? || auto_used?

      vip_user = site.vip_users.normal.where(user_id: user.id).first # 避免历史数据错乱导致的不一至

      if activity_prize.try(:point_prize?) && vip_user.present? && vip_user.normal? 
        transaction do
          update_attributes!(status: USED, used_at: Time.now, applicable: applicable, description: description)
          if point_gift_exchange? || red_packet?
            consumable.used!
          end

          shop_branch_id = applicable.is_a?(ShopBranch) ? applicable.id: nil

          vip_user.increase_points!(activity_prize.points)
          vip_user.point_transactions.create!(
            direction_type: PointTransaction::ACTIVITY_PRIZE,
            points: activity_prize.points,
            site_id: site.site_id,
            shop_branch_id: shop_branch_id,
            description: '活动积分奖励',
            pointable: self
          )

          save!
        end
      else # 会员未注册或无效会员
        errors.add('积分奖充值--', '会员未注册或无效会员')
        false
      end
    else # 普通奖
      transaction do
        update_attributes!(status: USED, used_at: Time.now, applicable: applicable, description: description)
        if point_gift_exchange? || red_packet?
          consumable.used!
        end
      end

      true # 不跑异常默认返回true
    end
  end

  def cancel!( applicable=nil, description=nil)
    transaction do
      update_attributes!(status: UNUSED, used_at: nil, applicable: nil, description: description)
      if consumable.is_a?(PointGiftExchange)
        consumable.unused!
      end
    end
  end

  def use_shop_name
    applicable.try(:name) || '商户总部'
  end

  def use_at
    used_at
  end

  def unexpired?
    expired_at.nil? || expired_at > Time.now
  end

  def mobile_or_vip_mobile
    wx_prize_mobile || mobile || vip_mobile
  end

  def guess_participation
    Guess::Participation.where(consume_id: id).first
  end

  def vip_user
    user.try(:vip_user)
  end

  def wx_prize_mobile
    wx_prize.try(:mobile)
  end

  def wx_prize_name
    wx_prize.try(:name)
  end

  def wx_prize_prize_name
    wx_prize.try(:prize_name)
  end

  def vip_mobile
    vip_user.try(:mobile)
  end

  def activity_or_coupon_name
    # coupon_name
    consumable.try(:name)
  end

  def activity_or_coupon_info
    # coupon_info
    if consumable_type == 'Activity'
      [activity_prize.try(:title), activity_prize.try(:prize)].compact.join('-')
    else
      coupon_info
    end
  end

  def state_name
    if used?
      status_name
    else
      unexpired? ? status_name : '已过期'
    end
  end

  def baseinfo
    "<tr><td>优惠券名称:</td><td>#{coupon_name}</td></tr>
    <tr><td>SN码:</td><td>#{code}</td></tr>
    <tr><td>领取时间:</td><td>#{created_at.to_s}</td></tr>
    <tr><td>状态:</td><td>#{state_name}</td></tr>"
  end

  def shop_branch_name
    if applicable_type == 'ShopBranch'
      applicable.try(:name) || '商户总部'
    end
  end

  def coupon
    consumable if consumable_type == 'Coupon'
  end

  def activity
    consumable if consumable_type == 'Activity'
  end

  def coupon_name
    consumable.try(:name) if consumable_type == 'Coupon'
  end

  def rqrcode
    return nil if code.blank?
    RQRCode::QRCode.new(code, :size => 4, :level => :h ).to_img.resize(90, 90).to_data_url
  end

  def coupon_info
     consumable.try(:info) if consumable_type == 'Coupon'
  end

  def expired?
    !unexpired? && unused?
  end

  def can_use?
    unexpired? && unused?
  end

  def coupon_can_use?
    coupon && can_use? && coupon.use_start <= Time.now
  end

  def activity_can_use?
    prize_start = Time.parse(activity.extend.prize_start)  rescue nil
    activity && can_use? && (prize_start.nil? || prize_start <= Time.now )
  end

  def unfold_can_use?
    activity_can_use? || coupon_can_use?
  end

  def link_class
    case
      when can_use? then 'c-use'
      when used?    then 'c-used'
      when expired? then 'c-overdue'
    end
  end

  def sn_code_type_name
    case
      when point_gift_exchange? then "礼品券"
      when red_packet?          then '节日礼包'
      when activity?            then '活动'
      else
        "优惠劵"
    end
  end

  def name
    point_gift_exchange? ? consumable.point_gift.name : consumable.name
  end

  def user_type
    point_gift_exchange? ? 'VipUser' : 'User'
  end

  # def user_id
  #   point_gift_exchange? ? consumable.vip_user_id : user_id
  # end

  def user_name
    point_gift_exchange? ? consumable.vip_user.name : user.nickname
  end

  def user_mobile
    point_gift_exchange? ? consumable.vip_user.mobile : user.mobile
  end

  def shop_branch_count
    if point_gift_exchange?
      consumable.point_gift.shop_branch_limited? ? consumable.point_gift.shop_branch_ids.length : "不限制"
    elsif coupon?
      consumable.shop_branch_limited? ? consumable.shop_branch_ids.length : "不限制"
    end
  end

  def validate_shop_branchs(shop_branch_id)
    if point_gift_exchange?
      consumable.point_gift.shop_branch_limited? ? consumable.point_gift.shop_branch_ids.include?(shop_branch_id) : true
    elsif coupon?
      consumable.shop_branch_limited? ? consumable.shop_branch_ids.include?(shop_branch_id) : true
    end
  end

  def use_consume(shop_branch)
    if point_gift_exchange?
      use!( shop_branch )
    elsif coupon?
      update_attributes(status: Consume::USED, applicable_type: 'ShopBranch', applicable_id: shop_branch.try(:id), used_at: Time.now)
    end
  end

  def auto_use_point_prize_consume!
    return false if used? || auto_used?

    if activity_prize.try(:point_prize?) # 积分奖需要判断是否是会员
      vip_user = site.vip_users.normal.where(user_id: user.id).first # 避免历史数据错乱导致的不一至

      if activity_prize.try(:point_prize?) && vip_user.present? && vip_user.normal? 
        transaction do
          update_attributes!(status: AUTO_USED, used_at: Time.now)
          if point_gift_exchange? || red_packet?
            consumable.used!
          end

          vip_user.increase_points!(activity_prize.points)
          vip_user.point_transactions.create!(
            direction_type: PointTransaction::ACTIVITY_PRIZE,
            points: activity_prize.points,
            site_id: site.site_id,
            description: '活动积分奖励',
            pointable: self
          )
          save!
        end
      else # 会员未注册或无效会员
        errors.add('积分奖充值--', '会员未注册或无效会员')
        false
      end
    end
  end

  private
    def generate_mobile
      self.mobile = self.mobile_or_vip_mobile if self.mobile.blank?
    end

    def generate_code
      self.code = ::SnCodeGenerator.generate_code(self)
    end

end
