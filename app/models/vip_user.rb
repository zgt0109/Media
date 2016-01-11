class VipUser < ActiveRecord::Base
  include HasBarcode
  has_barcode :barcode, :outputter => :svg, :type => :code_128, :value => Proc.new { |p| p.user_no }

  has_secure_password validations: false

  attr_accessor :recharge_given_privilege, :recharge_discount_vip_privilege
  store :meta, accessors: [:total_recharge_amount, :total_consume_amount, :avatar]

  validates :name, :mobile, presence: true
  validates :mobile, uniqueness: { scope: :wx_mp_user_id, case_sensitive: false }
  validates :user_no, uniqueness: { scope: :wx_mp_user_id }
  validates :custom_user_no, uniqueness: { scope: :wx_mp_user_id }, allow_blank: true

  validates :password, presence: true, length: { is: 6 }, if: :can_validate?

  enum_attr :status, in: [
    ['normal',    1, '正常'],
    ['inactive',  0, '待激活'],
    ['freeze',   -1, '已冻结'],
    ['pending',  -2, '待审核'],
    ['rejected', -3, '拒绝发卡'],
    ['deleted',  -4, '已删除']
  ]
  alias reject! rejected!

  enum_attr :gender, in: [
    ['secret', 0, '保密'],
    ['male',   1, '男'],
    ['female', 2, '女']
  ]

  belongs_to :site

  delegate :vip_card, to: :wx_mp_user, allow_nil: true
  delegate :open_card_sms_notify?, to: :vip_card, allow_nil: true
  delegate :recharge_consume_sms_notify?, to: :vip_card, allow_nil: true
  delegate :openid, to: :wx_user, prefix: true, allow_nil: true

  belongs_to :user
  belongs_to :vip_group, counter_cache: true
  belongs_to :vip_grade, counter_cache: true

  has_many   :vip_user_messages, dependent: :destroy
  has_many   :vip_user_signs, dependent: :destroy
  has_many   :point_gift_exchanges, dependent: :destroy
  has_many   :point_transactions, dependent: :destroy
  has_many   :vip_user_transactions, dependent: :destroy
  has_many   :vip_recharge_orders, dependent: :destroy
  has_many   :activity_consumes
  has_many   :custom_values, dependent: :destroy
  has_many   :vip_privilege_transactions, dependent: :destroy
  has_many   :vip_givens, dependent: :destroy
  has_many   :consumes, through: :user
  has_many   :vip_grade_logs, dependent: :destroy
  has_many   :vip_packages_vip_users, dependent: :destroy
  has_many   :vip_package_item_consumes, dependent: :destroy

  scope :one_day, ->(day) { where("date(created_at) = ?", day) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :six_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 5.month), today) }
  scope :twelve_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.year), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :normal_and_freeze, -> { where(status: [1,-1]) }
  scope :name_like, -> (name) { where('name like ?', "%#{name}%") if name.present? }
  scope :by_grade, -> (grade_id) { where(vip_grade_id: grade_id) if grade_id }
  scope :by_custom_field, -> (custom_field_id, value) { joins(:custom_values).where("custom_values.custom_field_id=? and value=?", custom_field_id, value) if value.present? }
  scope :sorted, -> { order('user_no ASC') }
  scope :freeze_user, -> { where(status: -1) }
  scope :visible, -> {where(['vip_users.status not in (?)', VipUser::DELETED])}

  before_save -> { self.trade_token = SecureRandom.uuid }
  before_create :set_init_data
  after_create :send_sms_notification, :send_register_points
  after_save :set_upgrade_variables
  after_update :reset_vip_user_group_and_grade_counter
  after_commit :upgrade!

  qiniu_image_for :avatar

  def self.by_group(group)
    conditions = group && group != '-1' ? {vip_group_id: group} : {}
    conditions[:vip_group_id] = nil if group == '-2'
    where(conditions)
  end

  def self.increase_points_by_spm(options = {})
    points = options[:points].to_i
    return {errcode: 40001, errmsg: "积分必须大于0"} if points < 0

    wx_mp_user = WxMpUser.where(openid: options[:mp_user_open_id]).first
    return {errcode: 40002, errmsg: "公众号不存在"} unless wx_mp_user

    out_trade_no = options[:out_trade_no].to_s
    return {errcode: 40005, errmsg: "订单不能重复操作"} if PointTransaction.where(out_trade_no: out_trade_no).first

    sign = Digest::MD5.hexdigest(out_trade_no + wx_mp_user.app_id.to_s)
    return {errcode: 40003, errmsg: "签名不正确"} unless sign == options[:trade_token]

    wx_user = wx_mp_user.wx_users.where(openid: options[:open_id]).first
    return {errcode: 40004, errmsg: "微信用户不存在"} unless wx_user

    vip_user = wx_mp_user.vip_users.visible.where(wx_user_id: wx_user.id).first

    unless vip_user
      vip_user = wx_user.create_vip_user(site_id: user.site_id, name: wx_user.openid, mobile: wx_user.openid)
      vip_user.status = INACTIVE
    end

    vip_user.usable_points += points
    vip_user.total_points  += points
    vip_user.save(validate: false)

    point_transaction = vip_user.point_transactions.new(
      direction_type: PointTransaction::SPM_IN,
      points: points,
      site_id: vip_user.site_id,
      out_trade_no: out_trade_no,
      description: '商品码活动积分奖励',
    )
    point_transaction.save(validate: false)

    { errcode: 0, errmsg: "ok", points: points }
  end

  def merchant_name
    vip_card.merchant_name.presence
  end

  def user_number
    custom_user_no.present? ? "#{user_no}(#{custom_user_no})" : user_no
  end

  def abnormal?
    !normal?
  end

  def related_activity
    vip_card && vip_card.activity
  end

  def vip_card
    wx_mp_user.vip_card
  end

  def rqrcode
     RQRCode::QRCode.new(user_number, :size => 4, :level => :h ).to_img.resize(90, 90)
  end

  def can_exchange?(gift, qty, given_point)
    usable_points + given_point >= (gift.points * qty)
  end

  def can_pay?(amount, discounted: false)
    return usable_amount >= amount if discounted
    usable_amount >= get_pay_amount(amount)
  end

  def increase_points!(points)
    change_points_by!(points) if points > 0
  end

  def decrease_points!(points)
    return if points < 0
    change_points_by!(-points)
  end

  # params应包含如下参数： direction(PointType#drection_type), description, shop_branch_id, amount_source
  def increase_amount!(amount,type,params)
    return if amount <= 0

    direction = params[:direction].to_i
    transaction do
      if direction == 1 # 如果是金额调节增加，则不使用会员特权赠送金额和积分
        change_amount = amount
        pay_amount, discount_amount, given_amount = amount, 0, 0
      else
        given_amount    = give_money(amount)
        change_amount   = amount + given_amount
        pay_amount      = recharge_discounted_amount(amount)
        discount_amount = amount - pay_amount
        give_point(amount, PointType::RECHARGE, params) if direction == 3
        qrcode_amount(amount, params[:direction])
      end
      change_amount_by!(change_amount)
      vip_user_transactions.create( direction_type: type,
                                    direction:      VipUserTransaction::IN,
                                    amount:         pay_amount,
                                    total_amount:   total_amount,
                                    usable_amount:  usable_amount,
                                    site_id:    site_id,
                                    payment_type:   params[:payment_type],
                                    order_no:       params[:order_no],
                                    description:    params[:description],
                                    extra_remarks:  params[:extra_remarks],
                                    shop_branch_id: params[:current_shop_branch_id],
                                    amount_source:  params[:amount_source])
      VipUserTransaction.create_recharge_given_transaction(self, discount_amount: discount_amount, given_amount: given_amount, shop_branch_id: params[:current_shop_branch_id])
      VipPrivilegeTransaction.create_recharge_transaction(self, recharge_given_privilege, recharge_discount_vip_privilege)
    end
    true
  end

  # params应包含如下参数： direction(PointType#drection_type), description, shop_branch_id, amount_source
  def decrease_amount!(amount, type, params, discounted: false)
    return if amount <= 0
    return change_amount_by!(-amount) if params[:able] == 'vip_packages'
    transaction do
      if params[:direction].to_i == 2 # 如果是金额调节减少，则不使用会员特权送钱和积分
        return unless change_amount_by!(-amount)
      else
        if type == '消费'
          privileged_amount = get_discounted_amount!(amount, VipPrivilege::CONSUME, params, discounted: discounted)
          return privileged_amount
        else
          return unless change_amount_by!(-amount)
          wx_user.qrcode_user_amount('vip_amount',-amount)
        end
      end
      vip_user_transactions.create( direction_type: type,
                                    direction:      VipUserTransaction::OUT,
                                    amount:         amount,
                                    total_amount:   total_amount,
                                    usable_amount:  usable_amount,
                                    site_id:    site.id,
                                    order_no:       params[:order_no],
                                    description:    params[:description],
                                    extra_remarks:  params[:extra_remarks],
                                    shop_branch_id: params[:current_shop_branch_id],
                                    amount_source:  params[:amount_source]).present?
    end
  end

  def qrcode_amount(amount,direction)
    vip_amount = direction == '3' ? recharge_discounted_amount(amount) : amount
    wx_user.qrcode_user_amount('vip_amount',vip_amount)
  end

  def give_point(amount, type, params)
    return unless site.vip_card.is_open_points?
    points = site.giving_points(amount, type, params, self)
    change_points_by!(points) if points > 0
  end

  def give_money(amount)
    self.recharge_given_privilege = usable_privileges.money.money_greater_than(amount).underway.greatest_value.find do |vip_privilege|
      vip_privilege.discount_unlimited?(self)
    end
    return recharge_given_privilege.try(:value).to_f
  end

  def create_point_gift_exchanges_by_gift(gift, qty, total_points, vip_given)
    description = "使用会员关怀 #{vip_given.vip_care.name} 赠送积分：#{vip_given.value}积分" if vip_given
    point_gift_exchanges.create site: site, point_gift: gift, qty: qty, total_points: total_points, description: description
  end

  def create_point_transactions_by_gift(gift, total_points, vip_given)
    description = '积分兑换礼物'
    description << "，使用会员关怀 #{vip_given.vip_care.name} 赠送积分：#{vip_given.value}积分" if vip_given
    point_transactions.create  site: site, pointable: gift, direction_type: PointTransaction::OUT, points: total_points, description: description
  end

  def exchange_gift(gift, qty, vip_given_id)
    vip_given = vip_givens.usable.find vip_given_id if vip_given_id.present?
    given_point = vip_given.try(:value).to_i
    return false unless can_exchange?(gift, qty, given_point)

    total_points = gift.points * qty
    transaction do
      point_gift_exchange = create_point_gift_exchanges_by_gift(gift, qty, total_points, vip_given)
      wx_user.consumes.create wx_mp_user: wx_mp_user, consumable: point_gift_exchange, expired_at: gift.award_time_end_at
      create_point_transactions_by_gift(gift, total_points, vip_given)
      decrease_points!( total_points - given_point )
      vip_given.try(:used!)
    end
    true
  end

  def usable_privileges
    vip_grade.vip_privileges.active.unexpired rescue VipPrivilege.none
  end

  def vip_grade_name
    vip_grade ? vip_grade.name : site.vip_card.init_grade_name
  end

  def today_signed?
    vip_user_signs.today.exists?
  end

  def point_gift_exchanged?(gift)
    point_gift_exchanges.where(point_gift_id: gift.id).exists?
  end

  def is_checkin?(point_type)
    last_checkin_date == Date.yesterday ? self.succ_checkin_days += 1 : self.succ_checkin_days = 1
    self.succ_checkin_days = 0 if succ_checkin_days == point_type.try(:succ_checkin_days)
    save && succ_checkin_days == 0
  end

  def last_checkin_date
    vip_user_signs.maximum(:date)
  end

  def recharge_discounted_amount(amount)
    self.recharge_discount_vip_privilege = recharge_discount_privilege(amount)
    if recharge_discount_vip_privilege
      amount = amount * recharge_discount_vip_privilege.value / 10
    end
    amount.to_f.round(2)
  end

  def recharge_discount_privileges
    usable_privileges.recharge.discount.underway.greatest
  end

  def recharge_discount_privilege(amount)
    recharge_discount_privileges.find do |vip_privilege|
      amount >= vip_privilege.amount && vip_privilege.discount_unlimited?(self)
    end
  end

  def recharge_point_privileges
    usable_privileges.recharge.point.underway.greatest_value
  end

  def recharge_point_privilege(amount)
    recharge_point_privileges.find do |vip_privilege|
      vip_privilege.point_unlimited?(self) && recharge_point_type(amount)
    end
  end

  def recharge_money_privileges
    usable_privileges.recharge.money.underway.greatest
  end

  def recharge_money_privilege(amount)
    recharge_money_privileges.find do |vip_privilege|
      amount >= vip_privilege.amount && vip_privilege.discount_unlimited?(self)
    end
  end

  def recharge_point_type(amount)
    site.point_types.normal.recharge.greatest.find do |point_type|
      amount >= point_type.amount
    end
  end

  def consumed_amount(amount)
    vip_privilege = consume_discount_privilege(amount)
    if vip_privilege
      amount = amount * vip_privilege.value / 10
    end
    amount.to_f.round(2)
  end

  def consume_discount_privileges
    usable_privileges.consume.discount.underway.greatest
  end

  def consume_discount_privilege(amount)
    consume_discount_privileges.find do |vip_privilege|
      amount >= vip_privilege.amount && vip_privilege.discount_unlimited?(self)
    end
  end

  def consume_point_privileges
    usable_privileges.consume.point.underway.greatest_value
  end

  def consume_point_privilege(amount)
    consume_point_privileges.find do |vip_privilege|
      vip_privilege.point_unlimited?(self) && consume_point_type(amount)
    end
  end

  def consume_point_type(amount)
    site.point_types.normal.consume.greatest.find do |point_type|
      amount >= point_type.amount
    end
  end

  def human_status_name
    case
    when normal?   then '正常'
    when freeze?   then '已被冻结'
    when rejected? then '申请已被拒绝'
    when pending?  then '正在审核中'
    end
  end

  def get_pay_amount( amount )
    vip_privilege = usable_privileges.consume.discount.underway.greatest.find do |vip_privilege|
      amount >= vip_privilege.amount && vip_privilege.discount_unlimited?(self)
    end
    amount = amount * vip_privilege.value / 10 if vip_privilege
    amount
  end

  def signin
    point_type = site.point_types.checkin.first
    return false unless point_type

    point1 = point_type.points if point_type.checkin_enabled
    point2 = point_type.succ_checkin_points if point_type.succ_checkin_enabled && is_checkin?(point_type)
    point  = point1.to_i + point2.to_i

    return 0 if point == 0

    transaction do
      vip_user_sign     = vip_user_signs.create!(site_id: site_id, date: Date.today, points: point )
      point_transaction = point_transactions.create!(site_id: site_id, point_type_id: point_type.id, direction_type: PointTransaction::IN, points: point, description: "签到" )
      increase_points!(point)
    end
    point
  end

  def get_discounted_amount!(amount, type, params, pay: true, discounted: false)
    if !discounted # 如果传入的amount不是折后价，则进行“打折”操作
      vip_privilege = usable_privileges.discount.underway.where(category: type).greatest.find do |vip_privilege|
        amount >= vip_privilege.amount && vip_privilege.discount_unlimited?(self)
      end
      amount = amount * vip_privilege.value / 10 if vip_privilege
    end
    if pay
      pay_by_cash = params[:payment_type].to_i == VipUserTransaction::BY_CASH
      if !pay_by_cash
        # 如果不是现金支付，就进行“扣款”操作，并将该操作写入消费记录
        amount_changed = change_amount_by!(-amount)
      end
      # 如果没有打折过，则进行加积分操作
      if !discounted && (pay_by_cash || amount_changed)
        give_point(amount, PointType::CONSUME, params)
      end
      if errors.blank?
        vip_user_transactions.create(direction_type: VipUserTransaction::PAY_DOWN,
                                    direction:       VipUserTransaction::OUT,
                                    amount:          amount,
                                    total_amount:    total_amount,
                                    usable_amount:   usable_amount,
                                    site_id:     site.id,
                                    order_no:        params[:order_no],
                                    extra_remarks:   params[:extra_remarks],
                                    description:     params[:description],
                                    payment_type:    params[:payment_type],
                                    transactionable: vip_privilege,
                                    shop_branch_id:  params[:current_shop_branch_id],
                                    amount_source:   params[:amount_source])
      end
    end
    amount
  end

  def upgrade_by_time
    return unless site
    vip_grades = site.vip_grades.by_time.normal.reverse_sorted
    next_grade = vip_grades.find { |g| created_at + ( g.value.year / 12 ) <= Time.now }
    upgrade_to! next_grade
  end

  def custom_field_with_value_names
    Hash[ custom_values.includes(:custom_field).map { |c| [c.custom_field.name, c.value] } ]
  end

  def change_amount_by!(amount)
    return false if amount == 0
    errors.add(:base, "余额不足") and return false if usable_amount + amount < 0
    self.usable_amount += amount
    self.total_amount  += amount if amount > 0
    save!
  end

  private
    def set_init_data
      self.status = PENDING if vip_card.try(:audited?) #需要审核
      self.vip_grade = site.vip_card.default_grade if vip_grade.blank?
      generate_user_no

      # if vip_card.is_open_points?
      #   register_point_type = site.point_types.register.normal.first
      #   self.usable_points += register_point_type.try(:points).to_i
      #   self.total_points  += register_point_type.try(:points).to_i
      # end
    end

    def generate_user_no
      max_user_no = wx_mp_user.vip_users.visible.maximum(:user_no) || 16880000
      self.user_no = max_user_no.succ
    end

    def change_points_by!(points)
      return false if points == 0 || usable_points + points < 0
      self.usable_points += points
      self.total_points  += points if points > 0
      save!
    end

    def upgrade_by_points
      next_grade = site.vip_grades.by_points.normal.reverse_sorted.where("value <= ?", total_points).first
      upgrade_to! next_grade
    end

    def upgrade_by_recharging
      amount     = vip_user_transactions.pay_up.sum(:amount)
      next_grade = site.vip_grades.normal.by_recharging.reverse_sorted.where("value <= ?", (amount + total_recharge_amount.to_f)).first
      upgrade_to! next_grade
    end

    def upgrade_by_consuming
      amount     = vip_user_transactions.pay_down.sum(:amount)
      next_grade = site.vip_grades.normal.by_consuming.reverse_sorted.where('value <= ?', (amount + total_consume_amount.to_f)).first
      upgrade_to! next_grade
    end

    def upgrade_by_amount
      upgrade_by_consuming
      upgrade_by_recharging
    end

    def upgrade_to!(next_grade)
      update_attributes!(vip_grade: next_grade) if next_grade.try(:sort).to_i > vip_grade.try(:sort).to_i
    end

    def upgrade!
      upgrade_by_points if @can_upgrade_by_points
      upgrade_by_amount if @can_upgrade_by_amount
    end

    def set_upgrade_variables
      @can_upgrade_by_points = usable_points_changed?
      @can_upgrade_by_amount = usable_amount_changed?
    end

    def send_sms_notification
      message = "恭喜您已成功成为#{merchant_name}的会员，卡号为#{user_no}，即日起您即可享受我们的会员专有特权。"
      SmsService.new.singleSend(mobile, message) if normal? && open_card_sms_notify?
    end

    def send_register_points
      transaction do
        if vip_card.is_open_points?
          register_point_type = site.point_types.register.normal.first
          if register_point_type
            register_points = register_point_type.try(:points).to_i

            update_attributes(usable_points: register_points, total_points: register_points)

            # give_point(register_points, PointType::REGISTER, direction: PointTransaction::REGISTER_CARD_IN, description: '领卡赠送积分')
            point_transactions.create(direction_type: PointTransaction::REGISTER_CARD_IN, points: register_points, site_id: site_id, description: '领卡赠送积分')
          end
        end
      end
    end

    def reset_vip_user_group_and_grade_counter
      if vip_grade_id_changed?
        VipGrade.reset_counters(vip_grade_id_was, :vip_users) if vip_grade_id_was.to_i > 0
        VipGrade.reset_counters(vip_grade_id, :vip_users) if vip_grade_id.to_i > 0
      end

      if vip_group_id_changed?
        VipGroup.reset_counters(vip_group_id_was, :vip_users) if vip_group_id_was.to_i > 0
        VipGroup.reset_counters(vip_group_id, :vip_users) if vip_group_id.to_i > 0
      end
    end
end
