# coding: utf-8
class WxUser < ActiveRecord::Base
  validates :openid, presence: true

  belongs_to :supplier
  belongs_to :wx_mp_user

  has_one :vip_user
  has_one :broker, class_name: '::Brokerage::Broker'

  has_many :wx_wall_users
  has_many :wx_shake_users
  has_many :wx_participates
  has_many :guess_participations, class_name: 'Guess::Participation'
  has_many :wx_prizes
  has_many :custom_values
  has_many :activity_users
  has_many :activity_consumes
  has_many :activity_users
  has_many :activity_groups
  has_many :leaving_messages, as: :replier
  has_many :addresses, class_name: 'WxUserAddress', dependent: :destroy
  has_many :ec_carts
  has_many :orders, class_name: 'EcOrder'
  has_many :booking_orders
  has_many :group_orders
  has_many :hospital_orders
  has_many :hospital_comments
  has_many :donation_orders
  has_many :trip_orders
  has_many :reservation_orders
  has_many :lottery_draws
  has_many :user_voices
  has_many :share_photo_comments
  has_many :share_photo_likes
  has_many :share_photos
  has_many :consumes
  has_many :govchats
  has_many :govmails
  has_many :qrcode_logs
  has_many :qrcode_users
  has_many :wbbs_topics, as: :poster
  has_many :wbbs_notifications, as: :notifier
  has_many :repairs, class_name: 'WxPlotRepairComplain', conditions: { category: WxPlotRepairComplain::REPAIR }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :complain_advices, class_name: 'WxPlotRepairComplain', conditions: { category: [WxPlotCategory::COMPLAIN, WxPlotCategory::ADVICE] }, order: 'wx_plot_repair_complains.created_at DESC'
  has_many :wx_invites, foreign_key: :from_wx_user_id

  acts_as_follower

  scope :message_forbidden, ->{ where(leave_message_forbidden: 1)}
  scope :message_normal, ->{ where(leave_message_forbidden: 0)}

  MATCH_TYPE_OPTIONS = [
      ['normal', 1, '正常模式'],
      ['postcard', 2, '打印模式'],
      ['share_photos', 3, '晒图模式'],
      ['greet', 4, '贺卡模式'],
      ['house_live_photos', 5, '实景拍摄模式'],
      ['print', 6, '打印模式'],
      ['wifi', 7, 'wifi模式'],
      ['welomo_print', 8, '通用打印模式'],
      ['hanming_wifi', 9, '汉明wifi'],
      ['kefu', 10, '人工客服模式'],
      ['kefu_rate', 11, '人工客服评价模式'],
      ['wx_wall_mode', 12, '微信墙模式'],
      ['wx_shake_mode', 13, '摇一摇模式']
  ]
  enum_attr :match_type, in: MATCH_TYPE_OPTIONS

  enum_attr :status, :in => [
    ['unsubscribe', 0, '未关注'],
    ['subscribe',   1, '关注']
  ]

  alias_attribute :subscribe, :status

  # options: wx_user_openid, wx_mp_user_openid, client_type 1:QQ 2:微信
  def self.follow(wx_mp_user, options = {})
    return unless wx_mp_user

    options = HashWithIndifferentAccess.new(options)
    wx_mp_user.update_openid_to(options[:wx_mp_user_openid])
    wx_user = wx_mp_user.wx_users.where(openid: options[:wx_user_openid]).first_or_create

    attrs = { wx_mp_user_id: wx_mp_user.id, supplier_id: wx_mp_user.supplier_id }
    attrs.merge!(userable_type: 'QqUser') if options[:client_type].to_i == 1
    attrs.merge!(status: options[:status]) if options[:status].present?
    wx_user.attributes = attrs
    wx_user.save if wx_user.changed?

    wx_user.check_recommend

    wx_user
  end

  def to_s
    nickname || openid || id.to_s
  end

  def check_recommend
    recommend =  WxInvite.recommend.pending_recommend.where(to_wx_user_id: id).last
    return unless recommend

    if wx_mp_user && wx_mp_user.auth_service? && wx_mp_user.is_oauth?
      attrs = Weixin.get_wx_user_info(wx_mp_user, openid).to_h
      attrs['nickname'] = attrs['nickname'].to_s.chars.select { |c| c.ord <= 65535 }.join if attrs['nickname'].present?
      if attrs.present?
        self.attributes = attrs
        save if changed?
      end
    end
    recommend.recommended!
  end

  def related_mobile
    vip_mobile || consumes_mobile
  end

  def consumes_mobile
    activity_consumes.pluck(:mobile).uniq.compact.last
  end

  def consumes_for_activity(activity)
    if activity.guess? && activity.guess_setting.prize
      consumes.where(consumable_id: activity.guess_setting.prize_id, consumable_type: activity.guess_setting.prize_type)
    end
  end

  def vip_mobile
    vip_user.try(:mobile)
  end

  def applicable_for_coupon_by_vip?(coupon, vip)
    return false if vip.nil? || !vip.normal?
    coupon.usable_vip_grades.include?(vip.vip_grade)
  end

  MATCH_TYPE_OPTIONS.map(&:first).each do |match_type|
    define_method "#{match_type}!" do
      update_attributes(match_type: WxUser.const_get(match_type.upcase), match_at: Time.now)
    end
  end

  def axis
    "#{location_x}, #{location_y}"
  end

  def reset_match_type
    normal! if greet? && updated_at <= 5.minutes.ago
  end

  def wbbs_topics_count
    wbbs_topics.count
  end

  def wbbs_up_count
    wbbs_topics.sum(:up_count)
  end

  def wbbs_reports_count
    wbbs_topics.sum(:reports_count)
  end

  def wbbs_replies_count
    wbbs_topics.sum(:wbbs_replies_count)
  end

  def has_info?
    nickname.present? && headimgurl.present?
  end

  def logo_url
    headimgurl || '/assets/wx_wall/user-img.jpg'
  end

  def belongs_to?(supplier)
    wx_mp_user_id == supplier.wx_mp_user.id
  end

  def guess_left_count(activity)
   return '无限' if (activity.guess_setting.user_day_answer_limit == -1 && activity.guess_setting.user_total_answer_limit == -1)
   arr = []
   if activity.guess_setting.user_day_answer_limit != -1
    arr << (activity.guess_setting.user_day_answer_limit - guess_participations_today(activity).count)
   end
   if activity.guess_setting.user_total_answer_limit != -1
    arr << (activity.guess_setting.user_total_answer_limit - guess_participations_all(activity).count)
   end
   [arr.min, 0].max
  end


  def can_not_guess?(activity)
    guess_left_count(activity) == 0
  end

  def guess_participations_today(activity)
    guess_participations_all(activity).today
  end

  def guess_participations_all(activity)
    activity.guess_participations.where(wx_user_id: id)
  end

  def gua_left_count(activity_id)
    left_count_arr = []
    activity = Activity.find(activity_id)
    self_lottery_draws = activity.lottery_draws.where(wx_user_id: id)
    if activity.activity_property.day_partake_limit != -1
      left_count_arr << activity.activity_property.day_partake_limit - self_lottery_draws.today.count #每人每天参与次数
    end

    if activity.activity_property.partake_limit != -1
      left_count_arr << activity.activity_property.partake_limit - self_lottery_draws.count  #每人参与总次数
    end

    left_count_arr.min || 99
  end

  def qrcode_user_amount(column_name,amount)
    qrcode = qrcode_logs.normal.earliest.first
    if qrcode
      qrcode_user = qrcode_users.where(supplier_id: supplier_id, qrcode_id: qrcode.try(:qrcode_id)).first_or_create
      qrcode_user[column_name] += amount.to_f
      qrcode_user.save if qrcode_user[column_name] >= 0
    end
  end

  def enter_kefu?
    normal? || kefu? || kefu_rate?
  end

  def enter_wx_wall?
    wx_wall_mode? && matched_in_minutes?(WxWallUser::LIVE_MINUTES)
  end

  def enter_wx_shake?
    wx_shake_mode? && matched_in_minutes?(WxShakeUser::LIVE_MINUTES)
  end

  def enter_postcard?
    postcard? && matched_in_minutes?(2)
  end

  def matched_in_minutes?(minutes)
    matched = match_at && match_at > minutes.minutes.ago
    normal! unless matched
    matched
  end
end
