class VipCare < ActiveRecord::Base
  attr_accessor :skip_validate_message_send_at
  belongs_to :vip_card
  belongs_to :given_coupon, class_name: 'Coupon'
  include Concerns::VipGivenGroupable

  serialize :given_coupon_ids, Array
  serialize :given_gift_ids, Array

  delegate :wx_mp_user, :wx_mp_user_id, :supplier, :supplier_name, to: :vip_card, allow_nil: true

  validates :care_day, presence: true, if: :festival?
  validates :name, :message_body, presence: true
  validate :message_send_at_greater_than_now

  scope :normal, -> { where('status != 3') }

  enum_attr :category, in: [
    ['festival', 1, '节日'],
    ['birthday', 2, '生日']
  ]

  enum_attr :care_month, in: [
    ['january',   1, '1月'],
    ['february',  2, '2月'],
    ['march',     3, '3月'],
    ['april',     4, '4月'],
    ['may',       5, '5月'],
    ['june',      6, '6月'],
    ['july',      7, '7月'],
    ['august',    8, '8月'],
    ['september', 9, '9月'],
    ['october',  10, '10月'],
    ['november', 11, '11月'],
    ['december', 12, '12月'],
  ]

  enum_attr :given_type, in: [
    ['point',      1, '积分'],
    # ['old_coupon', 2, '老优惠券'],
    # ['gift',       3, '礼品券'],
    ['coupon',     4, '优惠券']
  ]

  enum_attr :status, in: [
    ['unsent',  1, '未发送'],
    ['sent',    2, '已发送'],
    ['deleted', 3, '已删除']
  ]

  def receivers
    @receivers ||= (festival? ? festival_receivers : birthday_receivers)
  end

  def random_receivers
    @random_receivers ||= receivers.order('RAND()').to_a
  end

  def can_send_care?
    supplier && wx_mp_user && random_receivers.present?
  end

  def send_care!
    return unless can_send_care?
    transaction do
      case
        when respond_to?(:point?)      && point?      then send_point_care!
        when respond_to?(:old_coupon?) && old_coupon? then send_old_coupon_care!
        when respond_to?(:gift?)       && gift?       then send_gift_care!
        when respond_to?(:coupon?)     && coupon?     then send_coupon_care!
      end
      send!
    end
  end

  def send!
    self.attributes = {status: SENT, message_send_at: Time.now, skip_validate_message_send_at: true}
    save
  end

  private

  def send_point_care!
    random_receivers.each do |vip_user|
      content = get_message_body(vip_user.name)
      vip_user.vip_givens.create(vip_care_id: id, category: category, value: given_points, start_at: start_at, end_at: end_at)
      supplier.vip_user_messages.create(vip_user_id: vip_user.id, title: name, content: content)
    end
  end

  def send_old_coupon_care!
    given_coupon_ids.each do |id|
      activity        = Activity.find(id)
      limit_count = activity.activity_property.coupon_count - activity.activity_consumes.size
      next if limit_count <= 0

      random_receivers.take(limit_count).each do |vip_user|
        content = get_message_body(vip_user.name)
        consume = activity.activity_consumes.create(supplier_id: activity.supplier_id, wx_mp_user_id: wx_mp_user_id, wx_user_id: vip_user.wx_user_id)
        content.gsub!('{优惠券}', %Q[<a href='#{M_HOST}/app/vips/old_coupons?init_id=#{consume.id}'>#{activity.name}</a>])
        vip_user.vip_givens.create(vip_care_id: id, category: category, givable_id: id, givable_type: 'Activity')
        supplier.vip_user_messages.create(vip_user_id: vip_user.id, title: name, content: content)
      end
    end
  end

  def send_gift_care!
    given_gift_ids.each do |id|
      point_gift = PointGift.find(id)
      random_receivers.each do |vip_user|
        content             = get_message_body(vip_user.name)
        point_gift_exchange = PointGiftExchange.create(vip_user: vip_user, supplier: supplier, qty: 1, total_points: 0, description: "会员关怀：#{name}", point_gift: point_gift)
        consume             = Consume.create(wx_user_id: vip_user.wx_user_id, wx_mp_user_id: wx_mp_user_id, consumable: point_gift_exchange, expired_at: point_gift.award_time_end_at)
        content.gsub!('{礼品券}', %Q[<a href='#{M_HOST}/app/vips/exchanged?init_id=#{consume.id}'>#{point_gift.name}</a>])
        vip_user.vip_givens.create(vip_care_id: id, category: category, givable_id: id, givable_type: 'PointGift')
        supplier.vip_user_messages.create(vip_user_id: vip_user.id, title: name, content: content)
      end
    end
  end

  def send_coupon_care!
    limit_count = given_coupon.limit_count - given_coupon.consumes.count
    return if limit_count <= 0

    random_receivers.take(limit_count).each do |vip_user|
      begin
        content = get_message_body(vip_user.name)
        given_coupon.consumes.create!(wx_mp_user_id: vip_card.wx_mp_user_id, wx_user_id: vip_user.wx_user_id, consumable_id: given_coupon_id, consumable_type: 'Coupon')
        content.gsub!('{优惠券}', %Q[<a href="#{M_HOST}/#{vip_card.supplier_id}/coupons/my?openid=#{vip_user.wx_user.uid}">我的优惠券</a>])
        vip_user.vip_givens.create(vip_care_id: id, category: category, givable_id: given_coupon_id, givable_type: 'Coupon')
        supplier.vip_user_messages.create(vip_user_id: vip_user.id, title: name, content: content)
      rescue => e
        Rails.logger.error "send coupon to vip_user failed: coupon_id: #{given_coupon_id}, vip_user_id: #{vip_user}"
      end
    end
  end

  alias festival_receivers group_receivers

  def birthday_receivers
    birthday_field = vip_card.custom_fields.normal.where(name: '生日').first
    if birthday_field
      VipUser.joins(:custom_values).where('MONTH(value) = ?', care_month).where('custom_values.custom_field_id = ?', birthday_field.id)
    else
      VipUser.none
    end
  end

  def care_time
    festival? ? care_day.to_time : Time.local_time(Time.now.year, care_month, 1)
  end

  def get_message_body(receiver_name)
    content = reload.message_body
    content.gsub!('{商户名称}', supplier_name)
    content.gsub!('{会员姓名}', receiver_name)
    content
  end

  def start_at
    care_time.beginning_of_month
  end

  def end_at
    care_time.end_of_month
  end

  private
  def message_send_at_greater_than_now
    return if skip_validate_message_send_at

    if message_send_at? && message_send_at < Time.now
      errors.add(:message_send_at, '不能小于当前时间')
    end
  end

end
