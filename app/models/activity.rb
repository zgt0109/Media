class Activity < ActiveRecord::Base
  include WxReplyMessage
  include Rails.application.routes.url_helpers
  include Concerns::ActivityRankingList

  default_url_options[:host] = Settings.mhostname

  # 业务管理相关活动 type_ids
  OPERATION_TYPE_IDS = []
  HAS_STOPPED = -1; NOT_START = 1; WARM_UP = 2; UNDER_WAY = 3; HAS_ENDED = 4; SHOW_LIST = 5;
  HAS_STOPPED_NAME = '已终止'; NOT_START_NAME = "未开始"; WARM_UP_NAME = "预热中"; UNDER_WAY_NAME = "进行中"; HAS_ENDED_NAME = "已结束"; SHOW_LIST_NAME = "榜单公示期";NOT_SETTING_NAME = "未配置";
  SURVEY_STATUS = { "" => "全部", -2 => "已删除", -1 => "已结束", 0 => "未开始", 1 => "进行中" }
  APPLY_STATUS = { "" => "全部", -2 => "已删除", -1 => "已结束", 0 => "未开始", 1 => "进行中" }
  VOTE_STATUS = { "" => "全部", -2 => "已删除", -1 => "已结束", 0 => "未配置", 1 => "进行中", -3 => "未开始" }

  enum_attr :status, :in => [
    ['not_start', -3, '未开始'],
    ['deleted', -2, '已删除'],
    ['stopped', -1, '已终止'],
    ['setting', 0, '未配置'],
    ['setted', 1, '已配置'],
  ]

  enum_attr :deal_status, :in => [
    ['deal_failed', -1, '未成团'],
    ['pending', 0, '待处理'],
    ['deal_success', 1, '已成团'],
  ]

  enum_attr :vote_item_type, :in => [
    ['text', 1, '文字形式'],
    ['text_picture', 2, '文字加图片形式'],
    ['picture', 3, '图片形式'],
    ['text_link', 4, '文字加超链接形式'],
  ]

  has_time_range
  alias date_range start_at_end_at
  alias date_range= start_at_end_at=

  validates :name, presence: true, length: { maximum: 64 }
  validates :site_id, presence: true
  validates :activity_type, presence: true
  validates :keyword, presence: true, length: { maximum: 20 }
  validates :description, presence: true, if: :can_validate?
  validate :end_at_greater_than_start_at
  validate :ready_at_litter_than_start_at
  # validate :unique_keyword

  validates :summary, :presence => true, :if => :only_share_photo_setting?
  validates :page_title, :logo_key, :presence => true, :if => :wx_card?

  belongs_to :site
  belongs_to :activity_type
  belongs_to :activityable, polymorphic: true
  belongs_to :share_photo_setting
  belongs_to :shake
  belongs_to :brokerage, class_name: 'Brokerage::Setting'

  #TODO
  has_one :website, dependent: :destroy
  has_one :vip_card, dependent: :destroy
  has_one :trip
  has_one :greet
  has_one :scene_html
  has_one :share_setting, as: :shareable

  has_many :wx_participates, dependent: :destroy
  has_many :wx_prizes, dependent: :destroy
  has_many :custom_fields, as: :customized
  has_one :activity_property, dependent: :destroy
  has_one :ready_activity_notice, class_name: 'ActivityNotice', conditions: { activity_status: ActivityNotice::READY }
  has_one :active_activity_notice, class_name: 'ActivityNotice', conditions: { activity_status: ActivityNotice::ACTIVE }
  has_one :stopped_activity_notice, class_name: 'ActivityNotice', conditions: { activity_status: ActivityNotice::STOPPED }
  has_many :activity_notices, dependent: :destroy
  has_many :activity_properties, dependent: :destroy
  has_many :activity_consumes,dependent: :destroy
  has_many :activity_prizes, dependent: :destroy
  has_many :activity_prize_elements, dependent: :destroy
  has_many :fight_papers
  has_many :scenes
  has_many :reservation_orders

  has_many :govmailboxes
  has_many :govchats

  has_many :fight_report_cards, dependent: :destroy
  has_many :activity_users, dependent: :destroy
  has_many :activity_forms
  has_many :lottery_draws, dependent: :destroy
  has_many :form_fields, through: :activity_forms
  has_many :activity_enrolls, dependent: :destroy
  has_many :activity_vote_items, inverse_of: :activity, dependent: :destroy
  has_many :activity_user_vote_items, dependent: :destroy
  has_many :activity_groups, dependent: :destroy
  has_many :survey_questions, dependent: :destroy
  has_many :activity_feedbacks, dependent: :destroy
  has_many :albums, order: "albums.sort, albums.updated_at DESC"
  has_many :greets, dependent: :destroy
  has_many :coupons, dependent: :destroy
  has_many :coupon_consumes, through: :coupons, source: :consumes
  has_many :activity_prize_elements, dependent: :destroy
  has_many :donations
  has_many :donation_orders, through: :donations
  has_many :activities_fans_games, dependent: :destroy

  has_one  :guess_setting, class_name: 'Guess::Setting'
  has_many :guess_activity_questions, class_name: 'Guess::ActivityQuestion'
  has_many :guess_participations, class_name: 'Guess::Participation'
  has_many :guess_consumes, through: :guess_participations, source: :consume

  has_one :activity_setting
  delegate :associated_activity, to: :activity_setting, allow_nil: true

  has_many :brokerage_commission_types, class_name: 'Brokerage::CommissionType'

  has_many :red_packet_releases, class_name: 'RedPacket::Release'

  has_and_belongs_to_many :fans_games

  before_create :add_default_properties!#, :set_default_pic
  before_save :set_time_fields, :save_extend_serialized_content
  after_create :create_default_properties!, :create_default_custom_field
  after_save :set_update_status_plan, :set_update_status
  after_destroy :delete_ranking_list

  accepts_nested_attributes_for :activity_prizes, limit: 6
  accepts_nested_attributes_for :activity_property, :activity_notices, :activity_forms, :share_setting
  accepts_nested_attributes_for :activity_vote_items, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? && attributes['pic_key'].blank? && attributes['link'].blank? }
  accepts_nested_attributes_for :website, :vip_card, :site, :activities_fans_games
  accepts_nested_attributes_for :ready_activity_notice, :active_activity_notice, :stopped_activity_notice
  accepts_nested_attributes_for :guess_setting, :activity_setting

  scope :marketing_activities, -> { where(activity_type_id: [3,4,5,8,25,28]) }
  scope :show, -> { where("activities.status > ? or activities.status = ?", -2, -3)}
  scope :active, -> { where("activities.status >= ?", 0) }
  scope :material_active, -> { where("activities.status >= ? and activities.activity_type_id not in (?)", 0, [37,38,55]) }
  scope :valid, -> { where(status: [0, 1, -3]).where("end_at IS NULL OR end_at > ?", Time.now) }
  scope :completed, -> { where('activities.end_at < ?', Time.now) }
  # scope :configurable, -> { where(status: 0) }
  scope :starting, -> { where("(activities.ready_at < :time and activities.end_at > :time) OR activities.activity_type_id = 24", time: Time.now)}
  scope :vote_need_start, -> { where("activities.activity_type_id = ? AND activities.start_at <= ? AND activities.end_at >= ? AND activities.status != ?", 12, Time.now, Time.now, Activity::DELETED) }
  scope :vote_need_stop, -> { where("activities.activity_type_id = ? AND activities.end_at <= ? AND activities.status != ?", 12, Time.now, Activity::DELETED) }
  # 未过期的活动
  scope :unexpired, -> { where("activities.end_at is null or activities.end_at > :time", time: Time.now)}

  scope :old_coupon, -> { where(activity_type_id: 3) }
  scope :coupon, -> { where(activity_type_id: 62) }
  scope :reservations, -> { where(activity_type_id: 63) }

  enum_attr :activity_type_id, in: ActivityType::ENUM_ID_OPTIONS

  delegate :consume_day_allow_count, to: :activity_property, allow_nil: true
  delegate :consume_day_allow_count=, to: :activity_property, allow_nil: true
  delegate :plot_related?, to: :activity_type, allow_nil: true
  delegate :title, :pic_url, :summary, to: :share_setting, prefix: true, allow_nil: true

  class << self

    # 根据关键字获取最合适的活动
    def get_activity_by_keyword(keyword, site_id)
      site_id = site_id.to_i
      keyword = keyword.to_s.downcase
      return nil if site_id == 0 || keyword.blank?


      # 精确匹配
      activities = Activity.where("site_id = ? and status not in (-2) and lower(activities.keyword) = ? ", site_id, keyword).order("status DESC,end_at DESC")

      # 模糊匹配
      if activities.blank?
        activities = Activity.where("site_id = ? and status not in (-2) and lower(activities.keyword) like ? ", site_id, "%#{keyword}%").order("status DESC,end_at DESC")
      end

      # 反向模糊匹配
      if activities.blank?
        activities = Activity.where("site_id = ? and status not in (-2) and ? like CONCAT('%', activities.keyword, '%')", site_id, keyword).order("status DESC,end_at DESC")
      end

      activities.each do |activity|
        if activity.operation? || activity.surveys? || activity.message? || activity.vote? || activity.enroll?
          # 如果是 微报名，微投票，微调研 或 微留言
          return activity
        elsif activity.guess? || activity.red_packet?
          return activity
        elsif activity.wx_print? || activity.exit_wx_print? || activity.hanming_wifi?
          return activity
        elsif (!activity.stopped? && (activity.wx_wall? && activity.activity_status == Activity::NOT_START  && activity.activityable && activity.activityable.pre_join?))
          # 如果是 微信墙
          return activity
        elsif activity.setted? && activity.wave? && [WARM_UP, UNDER_WAY, HAS_ENDED].include?(activity.activity_status)
          return activity
        elsif activity.setted? && activity.unfold? && [NOT_START, UNDER_WAY, HAS_ENDED].include?(activity.activity_status)
          return activity
        elsif (activity.setted? || activity.stopped?) && activity.recommend?
          return activity
       elsif activity.setted? && (activity.unfold? || activity.gua? || activity.wheel?  || activity.slot? || activity.hit_egg? || activity.fight?) && [WARM_UP, UNDER_WAY, SHOW_LIST, HAS_ENDED].include?(activity.activity_status)
          return activity
        elsif  activity.setted? && [WARM_UP, UNDER_WAY].include?(activity.activity_status)
          return activity
        elsif (!activity.stopped? && (activity.hotel? or activity.wshop? or activity.wmall? or activity.wmall_shop? or activity.wmall_coupon?))
          return activity
        elsif activity.micro_aid?
          return activity
        end
      end
      return nil
    end

    def status_options_by_type_id(type_id)
      if OPERATION_TYPE_IDS.include?(type_id)
        if type_id == 10
          APPLY_STATUS
        elsif type_id == 15
          SURVEY_STATUS
        else
          VOTE_STATUS
        end.map{|e| e.first != -2 && e.reverse || nil}.compact
      elsif type_id == 12
        VOTE_STATUS.map{|e| e.first != -2 && e.reverse || nil}.compact
      elsif type_id == 10
        APPLY_STATUS.map{|e| e.first != -2 && e.reverse || nil}.compact
      elsif type_id == 15
        SURVEY_STATUS.map{|e| e.first != -2 && e.reverse || nil}.compact
      else
        self.status_options
      end
    end

  end

  def end_at_greater_than_start_at
    self.errors.add(:end_at, '不能小于活动开始时间') if self.start_at && self.end_at && self.end_at <= self.start_at
  end

  def ready_at_litter_than_start_at
    unless (unfold? || [10, 12, 75, 82].include?(activity_type_id))
      self.errors.add(:ready_at, "不能大于于活动开始时间") if self.start_at && self.ready_at && self.ready_at > self.start_at
    end
  end

  def duration_days
    if end_at.present? && start_at.present?
      (end_at.to_date - start_at.to_date) + 1
    end
  end

  def unique_keyword
    if active?
      activity = Activity.valid.where(site_id: site_id, keyword: keyword).first
      if activity && self != activity
        errors.add :keyword, '已经被使用'
      end
    end
  end

  def micro_aid_rule
    self.extend.rule
  end

  def unique_activity_type?
    [6,7,9,11].include?(self.activity_type_id)
  end

  def allow_repeat_apply?
    self.extend.allow_repeat_apply.to_i == 1
  end

  def show_enroll_list?
    self.extend.show_enroll_list.to_i == 1
  end

  #微投票显示百分数
  def allow_show_vote_percent?
    self.extend.allow_show_vote_percent.to_i == 0
  end

  #微投票显示投票数
  def allow_show_vote_count?
    self.extend.allow_show_vote_count.to_i == 1
  end

  #微投票/微调研是否填写用户信息
  def allow_show_user_tel?
    self.extend.allow_show_user_tel.to_i == 0
  end

  #微相册是否显示水印
  def show_watermark?
    self.extend.show_watermark.to_i == 1
  end

  #微相册顶部图片
  def album_watermark_img
    qiniu_image_url(self.extend.album_watermark_img)
  end

  def album_watermark_encode
    Qiniu::Utils.urlsafe_base64_encode(album_watermark_img+"?imageView2/2/w/150/h/60")
  end

  #微报名背景颜色
  def enroll_template_color
    self.extend.template_color.present? ? self.extend.template_color : 'D4DCF1'
  end

  #微报名字体颜色
  def enroll_font_color
    self.extend.font_color.present? ? self.extend.font_color : '283070'
  end

  def allow_wx_plot_sms
    self.extend.wx_plot_sms.to_i == 1
  end

  def vote_items_count
    @vote_items_count ||= activity_user_vote_items.count + activity_vote_items.sum(:adjust_votes)
  end

  def activity_user_vote_item_count
    @activity_user_vote_item_count ||= activity_users.count('distinct(user_id)') + activity_vote_items.sum(:adjust_votes)
  end

  def set_update_status_plan
    if self.operation? && (self.start_at || self.end_at)
      Sidekiq::Status.unschedule $redis.hget('activity_status_open_plan', self.id)
      Sidekiq::Status.unschedule $redis.hget('activity_status_close_plan', self.id)
      if self.start_at && self.start_at > Time.now
        plan_id = ActivitiesStatusWorker.perform_at(self.start_at, self.id, "open")
        $redis.hset('activity_status_open_plan', self.id, plan_id)
      end
      if self.end_at && self.end_at > Time.now
        plan_id = ActivitiesStatusWorker.perform_at(self.end_at, self.id, "close")
        $redis.hset('activity_status_close_plan', self.id, plan_id)
      end
    end
  end

  def set_update_status
    if operation? && ![-2,-3].include?(status)
      update_column(:status, (vote? && stopped?) ? -3 : 0) if start_at && start_at > Time.now
      update_column(:status, -1) if end_at && end_at < Time.now
    end
  end

  def duration(join_by = '<br />')
    durations = []
    if start_at.present? && end_at.present?
      return '不限制' if Time.diff(start_at, end_at)[:year] > 50
    end

    durations << (start_at.present? ? start_at.strftime("%Y-%m-%d %H:%M") : '不限制')
    durations << (end_at.present? ? end_at.strftime("%Y-%m-%d %H:%M") : '不限制')

    return '不限制' if durations.uniq == ['不限制']
    durations.join(join_by).html_safe
  end

  def countdown
    seconds = 0

    case activity_status
    when WARM_UP
      seconds = start_at - Time.now 
    when UNDER_WAY
      seconds = end_at - Time.now 
    end

    seconds 
  end

  def can_not_edit?
    (persisted? && setted? && activity_status != Activity::NOT_START && activity_status != Activity::WARM_UP) || stopped?
  end

  # 是否是业务管理的活动
  def operation?
    OPERATION_TYPE_IDS.include?(self.activity_type_id)
  end

  def lottery_activity?
    ( gua? || wheel? || hit_egg? || slot? ) rescue false
  end

  def only_share_photo_setting?
    activityable_type == "SharePhotoSetting"
  end

  def finished?
    [HAS_STOPPED,HAS_ENDED].include?(activity_status)
  end

  def wave_without_prepare?
    wave? && !activity_property.enable_prepare_settings
  end

  def activity_status
    now = Time.now
    if ready_at && now < ready_at
      NOT_START
    elsif ready_at && now >= ready_at && start_at && now < start_at
      if fight? || vote? || surveys? || self.wx_wall? || wave_without_prepare?
        NOT_START
      else
        WARM_UP
      end
    elsif start_at && now >= start_at && end_at && now < end_at
      if stopped?
        HAS_STOPPED
      else
        UNDER_WAY
      end
    else
      if fight? && end_at && now-(extend.show_list_day.to_i).day < end_at
        SHOW_LIST
      else
        HAS_ENDED
      end
    end
  end

  def create_default_custom_field
    if reservation? && custom_fields.blank?
      self.custom_fields.where(field_type: '单行文本', name: '姓名', field_format: 'string').first_or_create
      self.custom_fields.where(field_type: '单行文本', name: '电话', field_format: 'string').first_or_create
      self.custom_fields.where(field_type: '日期和时间', name: '预定日期', field_format: 'datetime').first_or_create
    elsif (govchat? || govmail?) && custom_fields.blank?
      self.custom_fields.where(field_type: '单行文本', name: '姓名', field_format: 'string').first_or_create
      self.custom_fields.where(field_type: '单行文本', name: '电话', field_format: 'string').first_or_create
    end
  end

  def activity_status_name
    now = Time.now
    if self.surveys?
      SURVEY_STATUS[self.status]
    elsif self.enroll?
      APPLY_STATUS[self.status]
    elsif self.vote?
      VOTE_STATUS[self.status]
    elsif self.red_packet?
      if start_at && now < start_at
        NOT_START_NAME
      elsif start_at && now >= start_at && end_at && now < end_at
        UNDER_WAY_NAME
      else
        HAS_ENDED_NAME
      end
    elsif ready_at && now < ready_at && !wx_wall?
      NOT_START_NAME
    elsif ready_at && now >= ready_at && start_at && now < start_at
      if fight? || vote? || surveys? || self.wx_wall? || wave_without_prepare? || guess?
        NOT_START_NAME
      else
        WARM_UP_NAME
      end
    elsif start_at && now >= start_at && end_at && now < end_at
      if stopped?
        HAS_STOPPED_NAME
      else
        UNDER_WAY_NAME
      end
    elsif (start_at && now >= start_at || start_at.nil?) && end_at.nil?
      if stopped?
        HAS_STOPPED_NAME
      else
        UNDER_WAY_NAME
      end
    else
      if fight? and end_at && now-(extend.show_list_day.to_i).day < end_at
        SHOW_LIST_NAME
      else
        HAS_ENDED_NAME
      end
    end
  end

  def activity_forms_status_name
    stopped? ? HAS_ENDED_NAME : UNDER_WAY_NAME
  end

  def complete_cupon
    return unless pending? and setted?
    return unless activity_property

    if end_at && end_at < Time.now and activity_property.min_people_num > activity_groups.count
      update_attributes(deal_status: DEAL_FAILED)
    elsif activity_property.min_people_num <= activity_groups.count
      deal_success!
    end

  end

  def add_default_properties!
    if self.operation?
      self.ready_at = Time.now + 1.seconds
      self.status = SETTING
    end
  end

  def create_default_properties!
    if website?
      Website.where(activity_id: id).first_or_create(site_id: site_id, name: site.wx_mp_user.try(:nickname), template_id: 1)
    elsif vip?
      merchant_name = site.account.nickname || site.wx_mp_user.nickname.presence
      VipCard.where(activity_id: id).first_or_create(merchant_name: merchant_name, site_id: site_id, name: "会员卡", cover_pic_key: 'FudiRXyXaCchVosPYrv22Ws9do1F', limit_privilege_count: 8)
    elsif [4,5,25].include?(activity_type_id)
      ActivityProperty.where(activity_id: id).first_or_create(activity_type_id: activity_type_id, repeat_draw_msg: "亲，抢券活动每人只能抽一次哦。", pic_key: ActivityProperty.win_pic_key)
    elsif activity_type_id == 28
      ActivityProperty.where(activity_id: id).first_or_create(activity_type_id: activity_type_id, repeat_draw_msg: "老虎机老虎机老虎机", pic_key: ActivityProperty.slot_pic_key)
   elsif wave?
      ActivityProperty.where(activity_id: id).first_or_create(activity_type_id: activity_type_id)
    elsif fight?
      days = [*(start_at.to_date..end_at.to_date)]
      if days.size < 8
        days.each_with_index do |day, i|
          fight_papers.create(site_id: site_id, activity_id: id, the_day: (i+1), active_date: day.to_date)
        end
      end
    elsif activity_type_id == 37
      Greet.create(:site_id => self.site_id, :activity_id => self.id )
    end

    default_notices = [
        { activity_type_id: 2, title: "申请微信会员卡", summary: "您尚未申请会员特权,快来点击申领吧!!", description: "申请微信会员卡", activity_status: 0 },
        { activity_type_id: 2, description: "会员卡", activity_status: 1 }.merge({title: "尊敬的会员{name}", summary: "尊敬的会员{name},您的会员卡号为{card_id},快来点击查看优惠信息吧!!"}),

        { activity_type_id: 3, title: "活动即将开始", pic_key: "FoIsarMzfL1wgy7nTeUDmmYqNXgo", summary: "您参与的优惠券活动将在{day}天{hour}小时{minute}分钟后开始！更多活动细节请点击页面查看详情~", description: "活动预热说明", activity_status: 0 },
        { activity_type_id: 3, pic_key: "FoIsarMzfL1wgy7nTeUDmmYqNXgo", description: "活动说明", activity_status: 1 }.merge({title: "中奖公告", summary: "你获得的SN码为:{code},了解优惠券特权请点击页面查看详情~"}),
        { activity_type_id: 3, title: "活动已经结束", pic_key: "Fl4TLAatoR7vum-Kb6UHURNopxNe", summary: "亲，下次早点哦~请继续关注我们的后续活动", description: "亲，下次早点哦~请继续关注我们的后续活动", activity_status: -1 },

        { activity_type_id: 4, title: "活动即将开始", pic_key: "Fkgsh_bQL0bVzzB--_vlgXh_XEg-", summary: "请点击进入刮刮卡活动预热页面", description: "活动预热说明", activity_status: 0 },
        { activity_type_id: 4, title: "活动开始，请进入页面开始刮奖", pic_key: "FjQ-lhEBIZgB7JrVcow4KPdWhWaG", summary: "请点击进入刮刮卡活动页面", description: "活动说明", activity_status: 1 },

        { activity_type_id: 5, title: "活动即将开始", pic_key: "Fl-25j4H93sfZ-B0ouwCusJfXK7D", summary: "请点击进入幸运大转盘活动预热页面", description: "活动预热说明", activity_status: 0 },
        { activity_type_id: 5, title: "活动开始，请进入页面开始抽奖", pic_key: "FobJBkcl_w3zH6TyiH9JSTQJkFJR", summary: "请点击进入幸运大转盘活动页面", description: "活动说明", activity_status: 1 },

        { activity_type_id: 25, title: "活动即将开始", pic_key: "FtGXJcP77amXP66bzhbZxirbO2pu", summary: "请点击进入砸金蛋活动预热页面", description: "活动预热说明", activity_status: 0 },
        { activity_type_id: 25, title: "活动开始，请进入活动页面开始砸金蛋", pic_key: "Fv97NDoE1hyhhWb8ddi4I6UneYSo", summary: "请点击进入砸金蛋活动页面", description: "活动开始说明", activity_status: 1 }
      ]

    default_notices.each do |attrs|
      if attrs[:activity_type_id] == activity_type_id
        attrs.delete(:activity_type_id)
        ActivityNotice.where(activity_id: id, activity_status: attrs[:activity_status]).first_or_create(attrs)
      end
    end

    %w(一等奖 二等奖 三等奖).each do |title|
      ActivityPrize.where(activity_id: id, title: title).first_or_create
    end if gua? || wheel? || hit_egg? || slot? || wave? || recommend?

    %w(元素一 元素二 元素三).each do |name|
      ActivityPrizeElement.where(activity_id: id, name: name).first_or_create(pic_key: ActivityPrizeElement.default_pic_key)
    end if slot?
  end

  def get_prize
    #抽取一个奖品
    prizes = self.activity_prizes.order(:title).select do |prize|
      lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count
    end
    lottery = rand(1000000)
    possible_lottery = 0
    prizes.find do |prize|
      possible_lottery += prize.prize_rate * 10000
      lottery < possible_lottery
    end
  end

  def total_donation_orders_count
    donation_orders.paid.count
  end

  def get_slot_prize(element_ids)
    #老虎机抽取一个奖品
    activity_prizes.order(:title).where(activity_element_ids: element_ids).find do |prize|
      lottery_draws.where(activity_prize_id: prize.id).count < prize.prize_count
    end
  end

  def slot_prizes_left_count
    @slot_prizes_left_count ||= activity_prizes.inject(0) do |left_count, prize|
      prize_left = prize.prize_count - lottery_draws.where(activity_prize_id: prize.id).count
      left_count + prize_left
    end
  end

  def generate_slot_element_ids
    prize = get_prize
    prize ? prize.activity_element_ids.to_s : generate_rand_slot_element_ids.to_s
  end

  def generate_rand_slot_element_ids
    ids = activity_prize_elements.with_name.pluck(:id)
    count = activity_prize_elements.with_name.count

    # in case count == 0
    new_activity_element_ids = [ ids[rand(1...count)], ids[rand(1...count)], ids[rand(1...count)]].join(',') rescue []

    unless activity_prizes.map(&:activity_element_ids).include?(new_activity_element_ids)
      return new_activity_element_ids
    else
      generate_rand_slot_element_ids
    end
  end

  def active?
    status >= 0 || status == -3
  end

  def active_coupon?
    active? && coupon?
  end

  def set_time_fields
    now = Time.now
    unless self.surveys? || self.enroll? || self.vote?
      self.start_at ||= now
      self.end_at   ||= (now + 100.years)
    end
    if wave?
      self.ready_at ||= start_at - 1.day
    elsif unfold?
      self.ready_at = start_at
    else
      self.ready_at ||= now
    end
  end

  def starting?
    return false unless start_at && end_at
    now = Time.now
    now >= start_at && now < end_at
  end

  def keyword_duplicated?(keyword, user = nil)
    user ||= site
    raise "Account can not be nil when validating uniqueness of activity's keyword" unless user
    repeats = user.activities.active.where(keyword: keyword).where('id <> ?', id)
    repeats.map(&:stop!)
    repeats.present?
  end

  def show_title_for_share_photo_setting
    if self.activity_type_id == ActivityType::SHARE_PHOTO
      return  "进入图片分享"
      #tag == 'title' ? "进入图片分享" : "图片分享"
    elsif self.activity_type_id == ActivityType::EXIT_SHARE_PHOTO
      return "退出图片分享"
    elsif self.activity_type_id == ActivityType::OTHER_PHOTOS
      return "查看他人晒图"
    elsif self.activity_type_id == ActivityType::MY_PHOTOS
      return '查看个人晒图'
    else
      ''
    end
  end

  # 是否允许开启
  def allow_active?
    result = false
    if unfold?
      if start_at < Time.now && end_at > Time.now
        result = [-1].include?(self.status)
      end
    elsif (self.start_at.nil? || self.start_at < Time.now)
      if self.surveys? && self.survey_questions.blank?
        # 如果是没有题目的微调研，不允许开启
      elsif self.vote? && self.setting?
        # 如果是未配置的微投票，不允许开启
      elsif [0, -1, -3].include?(self.status)
        # 已停止，未配置，已配置，以上三种状态的活动，允许开启
        if (self.end_at && self.end_at > Time.now) || self.end_at.nil?
            return true
        end
      end
    end

    result
  end

  def scene_qrcode
    RQRCode::QRCode.new(scene_url, :size => 8, :level => :h ).to_img.resize(200, 200).to_data_url
  end

  def scene_url
    "http://#{Settings.mhostname}/#{site_id}/scenes?aid=#{id}&version=#{scene_html.try(:version)}"
  end

  # 微投票状态相关属性 arrts[状态名称，是否允许开启，是否允许停止，是否允许删除]
  def vote_status_attrs
    case status
      when -3
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
          [NOT_START_NAME, true, false, true]
        end
      when 0
        [NOT_SETTING_NAME, false, false, true]
      when 1
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
         [UNDER_WAY_NAME, false, true, false]
        end
        #end_at.present? && end_at < Time.now ? [HAS_ENDED_NAME, false, false, true] : [UNDER_WAY_NAME, false, true, false]
      when -1
        end_at.present? && end_at < Time.now ? [HAS_ENDED_NAME, false, false, true] : [HAS_ENDED_NAME, true, false, true]
    end
  end

  # 微报名状态相关属性 arrts[状态名称，是否允许开启，是否允许停止，是否允许删除]
  def enroll_status_attrs
   #0未配置 save: 0
   #1已配置 时间满足： 进行中
   #-1已终止
    case status
      when 0
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
          [NOT_START_NAME, true, false, true]
        end
      when 1
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
         [UNDER_WAY_NAME, false, true, false]
        end
      when -1
       end_at.present? && end_at < Time.now ? [HAS_ENDED_NAME, false, false, true] : [HAS_ENDED_NAME, true, false, true]
    end
  end

  # 微调研状态相关属性 arrts[状态名称，是否允许开启，是否允许停止，是否允许删除]
  def survey_status_attrs
    case status
      when 0
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
          [NOT_START_NAME, true, false, true]
        end
      when 1
        if end_at.present? && end_at < Time.now
          [HAS_ENDED_NAME, false, false, true]
        elsif start_at.present? && start_at < Time.now
          [UNDER_WAY_NAME, false, true, false]
        elsif start_at.present? && start_at > Time.now
          [NOT_START_NAME, false, false, true]
        else
         [UNDER_WAY_NAME, false, true, false]
        end
      when -1
        end_at.present? && end_at < Time.now ? [HAS_ENDED_NAME, false, false, true] : [HAS_ENDED_NAME, true, false, true]
    end
  end

  # 是否允许停止
  def allow_stop?
    self.setted? && ![Activity::HAS_ENDED, Activity::HAS_STOPPED, Activity::NOT_START].include?(activity_status)
  end

  # 是否允许设置题目
  alias allow_set_question? surveys?

  # 是否允许删除
  def allow_delete?
    if surveys?
      end_at && Time.now >= end_at || stopped?
    else
      !self.setted?
    end
  end

  # 是否允许查看
  def allow_show?
    activity_status != Activity::NOT_START && activity_status != Activity::WARM_UP
  end

  # 是否允许编辑
  def allow_edit?
    (activity_status == Activity::NOT_START || activity_status == Activity::WARM_UP) && !stopped?
  end

  # 是否允许看统计报告
  def allow_show_report?
    setted? || stopped? || status == -3
  end

  def has_ranking_list?
    micro_aid?
  end

  def activity_qrcode_url
    # case
    #   when vote?  then mobile_vote_login_url(subdomain: mobile_subdomain, site_id: site_id, vote_id: id, anchor: "mp.weixin.qq.com")
    #   when surveys?  then mobile_survey_url(subdomain: mobile_subdomain, site_id: site_id, id: id, anchor: "mp.weixin.qq.com")
    # end
    respond_mobile_url
  end

  def vote_qrcode_download(type = 258)
    require 'RMagick'

    1.upto(12) do |size|
      break @qrcode = RQRCode::QRCode.new(activity_qrcode_url, size: size, level: :h).to_img.resize(1280, 1280) rescue next
    end

    img = Magick::Image::read_inline(@qrcode.to_data_url).first

    # if self.pic?
    #   mark = Magick::ImageList.new
    #   begin
    #     pic = pic_key.present? ? mark.from_blob(open(qiniu_image_url(pic_key)).read) : mark.read(pic.current_path)
    #     img = img.composite(pic.resize(260, 260), 510, 510, Magick::OverCompositeOp)
    #   rescue
    #   end
    # end

    Magick::ImageList.new.from_blob(img.to_blob).resize(type.to_i, type.to_i).to_blob
  end

  def description
    if self.stopped? && self.extend.closing_note.present?
      self.extend.closing_note
    else
      read_attribute("description")
    end
  end

  def consumes
    if recommend?
      Consume.where(consumable_type: 'Activity', consumable_id: id).where('activity_prize_id is null')
    else
      if self.extend.prize_type == 'coupon'
        Consume.where(consumable_type: 'Coupon', consumable_id: self.extend.prize_id)
      else
        Consume.where(consumable_type: 'Activity', consumable_id: id)
      end
    end
  end

  def extend
    @extend ||= Extend.new(read_attribute("extend"))
  end

  def save_extend_serialized_content
    value = self.extend.try(:serialized_content) || Marshal.dump({})
    write_attribute("extend", value)
  end

  def toggle_captcha_required!
    self.extend.captcha_required = !self.extend.captcha_required
    self.save
  end

  def mobile_subdomain
    [site_id.to_s, MOBILE_SUB_DOMAIN].join('.')
  end

  def respond_mobile_url(activity_notice = nil, options = {})
    activity_notice = activity_notice || activity_notices.active.first
    if gua? && setted?
      activity_notice = ActivityNotice.ready_or_active_notice(self, [WARM_UP, HAS_ENDED])
    elsif wheel? && setted?
      activity_notice = ActivityNotice.ready_or_active_notice(self)
    elsif consume?
      activity_notice = activity_notices.first
      wx_user = WxUser.where(openid: options[:openid]).first
      activity_consume = activity_consumes.where(site_id: site_id, user_id: wx_user.user_id).first
      option[:code] = activity_consume.try(:code)
    end

    _default_params = { subdomain: mobile_subdomain, site_id: site_id, aid: id, openid: options[:openid] }

    url = case
      when website?            then mobile_root_url(_default_params)
      when vip?                then app_vips_url(_default_params)
      when coupon?             then mobile_coupons_url(_default_params)
      when consume?            then app_consume_url(_default_params.merge(anid: activity_notice.id, code: option[:code]))
      when gua?                then app_gua_url(_default_params.merge(id: id, anid: activity_notice.id, source: 'notice'))
      when wheel?              then app_wheel_url(_default_params.merge(id: id, anid: activity_notice.id, source: 'notice'))
      when fight?              then app_fight_index_url(_default_params.merge(anid: activity_notice.id, m: 'index'))
      when slot?               then app_slots_url(_default_params)
      when hit_egg?            then app_hit_egg_url(_default_params.merge(id: id))
      when wave?               then mobile_waves_url(_default_params)
      when micro_aid?          then mobile_aids_url(_default_params)
      when book_dinner?        then book_dinner_mobile_shops_url(_default_params)
      when book_table?         then book_table_mobile_shops_url(_default_params)
      when take_out?           then take_out_mobile_shops_url(_default_params)
      when micro_store?        then mobile_micro_stores_url(_default_params)
      when enroll?             then new_app_activity_enroll_url(_default_params)
      when surveys?            then return_survey_activity_url(_default_params)
      when reservation?        then mobile_reservations_url(_default_params)
      when vote?
        stopped? ? mobile_vote_result_url(_default_params.merge(vote_id: id)) : mobile_vote_login_url(_default_params.merge(vote_id: id))
      when house?              then app_house_layouts_url(_default_params)
      when groups?             then app_activity_group_url(_default_params.merge(id: id))
      when car?                then return_car_url(_default_params)
      when weddings?           then mobile_weddings_url(_default_params.merge(wid: activityable_id))
      when album?              then mobile_albums_url(_default_params)
      when educations?         then app_educations_url(_default_params.merge(cid: activityable_id))
      when life?               then app_lives_url(_default_params.merge(id: activityable_id))
      when circle?             then app_business_circles_url(_default_params.merge(id: activityable_id))
      when message?            then app_leaving_messages_url(_default_params)
      when house_bespeak?      then new_app_house_market_url(_default_params)
      when house_seller?       then app_house_sellers_url(_default_params)
      when booking?            then mobile_bookings_url(_default_params)
      when group?              then mobile_groups_url(_default_params.merge(id: id))
      when hospital?           then mobile_hospital_doctors_url(_default_params)
      when trip?               then mobile_trips_url(_default_params)
      when business_shop?      then mobile_business_shop_url(site, activityable)
      when house_impression?   then app_house_impressions_url(_default_params)
      when house_live_photo?   then app_house_live_photos_url(_default_params)
      when house_intro?        then app_house_intros_url(_default_params)
      when wbbs_community?     then mobile_wbbs_topics_url(_default_params)
      when broche?             then mobile_broche_photos_url(_default_params)
      when plot_bulletin?      then bulletins_mobile_wx_plots_url(_default_params)
      when plot_repair?        then repair_complains_mobile_wx_plots_url(_default_params.merge(type: 'repair'))
      when plot_complain?      then repair_complains_mobile_wx_plots_url(_default_params.merge(type: 'complain'))
      when plot_telephone?     then telephones_mobile_wx_plots_url(_default_params)
      when plot_owner?         then owners_mobile_wx_plots_url(_default_params)
      when plot_life?          then lives_mobile_wx_plots_url(_default_params)
      when fans_game?          then mobile_fans_games_url(_default_params)
      when govmail?            then mobile_govmails_url(_default_params)
      when govchat?            then mobile_govchats_url(_default_params)
      when unfold?             then mobile_unfolds_url(_default_params)
      when wmall_coupon?       then wmall_coupon_url(wx_user_open_id: options[:openid], wx_mp_user_open_id: site.wx_mp_user.try(:openid), site_id: site_id)
      when scene?              then mobile_scenes_url(_default_params)
      when guess?              then mobile_guess_url(_default_params)
      when wx_card?            then mobile_wx_cards_url(_default_params.merge(wechat_card_js: 1))
      when brokerage?          then mobile_brokerages_url(_default_params)
      when red_packet?         then mobile_red_packets_url(_default_params)
      when greet?              then mobile_greet_cards_url(_default_params)
      when recommend?
        if site.wx_mp_user.authorized_auth_subscribe?
          mobile_recommends_url(_default_params)
        else
          mobile_recommends_url(_default_params)
        end
      when panoramagram?
        if activityable_type == 'Panoramagram'
          panorama_mobile_panoramagram_url(_default_params.merge(id: activityable_id))
        else
          mobile_panoramagrams_url(_default_params)
        end
      when donation?           then mobile_donations_url(stopped?.merge(wid: activityable_id))
      when wmall?              then wmall_root_url(wx_user_open_id: options[:openid], wx_mp_user_open_id: site.wx_mp_user.try(:openid), site_id: site_id)
      when wmall_shop?         then wmall_shop_url(shop_id: activityable_id, wx_user_open_id: options[:openid], wx_mp_user_open_id: site.wx_mp_user.try(:openid), site_id: site_id)
      when wshop? || ec?       then wshop_root_url(wx_mp_user_open_id: site.wx_mp_user.try(:openid), wx_user_openid: options[:openid])
      # when oa?                 then "#{OA_HOST}/woa-all/wx/#{site_id}/index?openid=#{options[:openid]}"
      when hotel?              then "#{HOTEL_HOST}/wehotel-all/weixin/mobile/website.jsp?site_id=#{site_id}&openid=#{options[:openid]}"
      when wifi?               then "http://m.chaowifi.com/auth/wechat.do?guid=#{options[:openid]}"
      when hanming_wifi?       then "#{activity.hanming_callback_url}?func=weixin&custom_wx_id=#{options[:openid]}&wx_id=#{site.wx_mp_user.openid}&ssid=winwemedia-#{site}&resulturl=#{hanming_callback_url}&resultAnchor=0"
      end
    url || ''
  end

  def return_survey_activity_url(options = {})
    wx_user = WxUser.where(openid: options[:openid]).first
    activity_user = ActivityUser.where(user_id: wx_user.user_id, activity_id: id).first if wx_user
    return mobile_survey_url(options.merge(id: id)) if activity_user.nil? || !setted?
    return success_mobile_survey_url(options.merge(id: id)) if activity_user.survey_finish?

    question = survey_questions.first
    question ? questions_mobile_survey_url(options.merge(id: id, qid: question.id)) : ''
  end

  def return_car_url(options = {})
    car_activity_notice = activityable
    case
      when car_activity_notice.blank?      then ''
      when car_activity_notice.repair?     then car_bespeak_mobile_car_shops_url(options.merge(bespeak_type: CarBespeak::REPAIR))
      when car_activity_notice.test_drive? then car_bespeak_mobile_car_shops_url(options.merge(bespeak_type: CarBespeak::TEST_DRIVE))
      when car_activity_notice.sales_rep?  then car_seller_mobile_car_shops_url(options.merge(seller_type: CarSeller::SALES_REP))
      when car_activity_notice.shop?       then mobile_car_shops_url(options)
      when car_activity_notice.owner?      then mobile_car_owners_url(options)
      when car_activity_notice.assistant?  then mobile_car_assistants_url(options)
    end
  end

  def return_mobile_share_photo_url(share_photo_id = nil)
    mobile_share_photo_url(subdomain: mobile_subdomain, site_id: site_id, id: share_photo_id, openid: options[:openid])
  end

  def hanming_callback_url
    if self['extend'].blank?
      "http://m.winwemedia.com"
    elsif self['extend'].to_s.start_with?("http")
      self['extend'].to_s
    else
      "http://#{self['extend'].to_s}"
    end
  end

  def activity_date
    if self.start_at && self.end_at
      "#{self.start_at.to_date} - #{self.end_at.to_date}"
    end
  end

  def activity_date=(str_dates)
    dates = str_dates.present? && str_dates.split(" - ") || []
    if dates.length == 0 || dates.length == 2
      self.start_at = dates.first
      self.end_at = dates.last
    end
  end

  def notice_title
    activity_notice = self.activity_notices.first
    activity_notice.try(:title).to_s
  end

  def bg_music_url
    bg_music.try(:qiniu_audio_url).try(:presence)
  end

  def bg_music
    Material.find_by_id(self.extend.audio_id)
  end

  def qiniu_pic_url
    bucket = (wmall? || wmall_shop? || wmall_coupon?) ? BUCKET_WMALL : BUCKET_PICTURES
    qiniu_image_url(pic_key, bucket: bucket)
  end

  def qiniu_pic_url_for_wmall
    qiniu_image_url(pic_key, bucket: BUCKET_WMALL)
  end

  def splash_url
    qiniu_image_url(extend.splash_key, bucket: BUCKET_PICTURES)
  end

  #模板背景图片
  def template_url
    qiniu_image_url(template_qiniu_key)
  end

  def template_qiniu_key
    extend.template_qiniu_key
  end

  def pic_display_url
    default_pic_url
  end

  def bg_pic_url
    qiniu_image_url(bg_pic_key)
  end

  def logo_url
    qiniu_image_url(logo_key)
  end

  def pic_url
    qiniu_pic_url || default_pic_url
  end

  def default_pic_url
    qiniu_image_url(default_pic_key)
  end

  def default_pic_key
    Concerns::ActivityQiniuPicKeys::KEY_MAPS[activity_type_id]
  end

  private
    def set_default_pic
      if self.pic_key.blank?
        self.pic_key = Concerns::ActivityQiniuPicKeys::KEY_MAPS[activity_type_id]
      end
    end
end
