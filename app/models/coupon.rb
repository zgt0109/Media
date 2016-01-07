class Coupon < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :activity
  belongs_to :wx_mp_user

  has_and_belongs_to_many :vip_grades
  has_and_belongs_to_many :shop_branches
  has_many :consumes, as: :consumable, dependent: :destroy

  acts_as_list scope: [ :supplier_id]

  scope :latest, -> { online.order('created_at DESC') }
  scope :can_apply, -> { online.where(':time BETWEEN apply_start AND apply_end', time: Time.now) }
  scope :can_use, -> { online.where(':time BETWEEN use_start AND use_end', time: Time.now) }
  scope :shop_branch_limited, -> { where(shop_branch_limited: true) }
  scope :shop_branch_unlimited, -> { where(shop_branch_limited: false) }
  scope :normal, -> { where(status: [1,2]) }
  scope :recent, -> { order('coupons.id DESC') }
  scope :mobile, -> { where(status: 1) }
  scope :sorted, -> { order('coupons.position ASC') }

  after_save :associate_shop_branches
  after_save :clear_data

  enum_attr :status, in: [
    ['online',  1, '有效'],
    ['offline', 2, '无效'],
    ['deleted', 0, '删除'],
  ]

  enum_attr :coupon_type, in: [
    %w(deduction_coupon 抵用券),
    %w(activity_coupon  活动券),
    %w(offline_coupon   线下券)
  ]

  validates :name, :apply_start, :apply_end, presence: true, unless: :offline_coupon?
  has_time_range start_at: :use_start, end_at: :use_end
  validates :use_start_use_end, presence: true
  validates :people_limit_count, :day_limit_count, presence: true, numericality: { greater_than_or_equal_to: -1, only_integer: true }
  validates :limit_count, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :value, :value_by, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :datetime_validate
  validates :name, uniqueness: { scope: :wx_mp_user_id, message: '优惠券名称不能重复' }
  validates :limit_count, numericality: {less_than_or_equal_to: 1000}, if: :offline_coupon?

  def usable_vip_grades
    if vip_only?
      vip_grades.visible.sorted
    else
      supplier.vip_card.vip_grades.visible.sorted
    end
  end

  def datetime_validate
    self.errors.add(:base, '领取结束时间不能小于领取开始时间') if self.apply_start && self.apply_end && self.apply_end < self.apply_start
    self.errors.add(:base, '使用结束时间不能小于使用开始时间') if self.use_start && self.use_end && self.use_end < self.use_start
  end

  def shop_branches_count
    if shop_branch_limited?
      shop_branch_ids.count
    else
      supplier.shop_branches.used.count
    end
  end

  def limited_for?(shop_branch)
    shop_branch_limited? && !shop_branch_ids.include?(shop_branch.id)
  end

  def info
    if value_by && value_by > 0
      "满#{value_by}减#{value}"
    else
      "#{value}元无限制券"
    end
  end

  def logo_url
    qiniu_image_url(qiniu_logo_key) || supplier.try(:website).try(:logo_url)
  end

  def qiniu_logo_key
    attributes['qiniu_logo_key'] || supplier.try(:website).try(:logo_key)
  end

  def appliable?
    limit_count_not_reach? && state_name  == '进行中'
  end

  def hold_count
    hold_count = 0
    supplier.activities.unfold.each do |activity|
      if activity.extend.prize_type == 'coupon' && activity.extend.prize_id.to_i == self.id
        if activity.deleted?
            hold_count = 0
        else
            if activity.activity_status == Activity::HAS_ENDED
              hold_count = 0
            else
              hold_count += activity.extend.prize_count.to_i - activity.wx_prizes.pluck(:consume_id).compact.uniq.count
            end
        end
      end
   end
   hold_count
  end

  def limit_count_avaliable
    limit_count - hold_count
  end

  def limit_count_not_reach?
    consumes.count < limit_count_avaliable
  end

  def usable_shop_branches
    if shop_branch_limited?
      shop_branches.used
    else
      supplier.shop_branches.used
    end
  end

  def expired?
    state_name == '已结束'
  end

  def can_apply_for_wxuser?(wx_user_id=nil)
    return false unless WxUser.where(id: wx_user_id).exists?
    appliable? && people_limit_count_not_reach?(wx_user_id) && day_limit_count_not_reach?
  end

  def can_apply_by_date?
   (apply_start <= Time.now) && (Time.now <= apply_end)
  end

  def over_apply_start?
    Time.now >= apply_start
  end

  def can_use_by_date?
   (use_start <= Time.now) && (Time.now <= use_end)
  end

  def people_limit_count_not_reach?(wx_user_id=nil)
    return true if people_limit_count == -1
    consumes.where(wx_user_id: wx_user_id).count < people_limit_count
  end

  def day_limit_count_not_reach?
    return true if day_limit_count == -1
    consumes.select { |consume|
      consume.created_at.to_date == Time.now.to_date
    }.count < self.day_limit_count
  end

  def state_name
    # return '进行中' if offline_coupon?

    if offline_coupon?
      if can_use_by_date?
        '进行中'
      elsif use_start > Time.now
        '未开始'
      else
        '已结束'
      end
    elsif online?
      if can_apply_by_date?
        '进行中'
      elsif apply_start > Time.now
        '未开始'
      else
        '已结束'
      end
    else
      '已停止'
    end
  end

  def create_offline_consumes
    if offline_coupon?
      OfflineCouponConsumeGenerateWorker.perform_async(id)
    end
  end

  def reset_offline_consumes
    if offline_coupon? && limit_count_changed?
      consumes.delete_all
      OfflineCouponConsumeGenerateWorker.perform_async(id)
    end
  end

  def link_class
    if expired?
      'c-overdue'
    elsif !limit_count_not_reach?
      'c-end'
    elsif appliable?
      'c-receive'
    end
  end

  private
    def set_offline_attributes
      return unless offline_coupon?

      self.people_limit_count = -1
      self.day_limit_count = -1
      self.vip_only = false
    end

    def associate_shop_branches
      self.shop_branch_ids = supplier.shop_branches.used.pluck(:id) unless shop_branch_limited?
    end

    def clear_data
      self.vip_grade_ids = [] unless vip_only?
      self.shop_branch_ids = [] unless shop_branch_limited?
    end

end
