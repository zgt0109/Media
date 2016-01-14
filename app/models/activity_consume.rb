class ActivityConsume < ActiveRecord::Base
  include HasBarcode

  belongs_to :user
  belongs_to :site
  belongs_to :activity
  belongs_to :vip_privilege
  belongs_to :activity_prize
  belongs_to :shop_branch
  belongs_to :activity_group
  has_one :send_record, class_name: RedPacket::SendRecord

  scope :created_at_today, -> {where(created_at: Time.now.beginning_of_day..Time.now.end_of_day)}
  scope :unexpired, -> { where("expire_at IS NULL OR expire_at >= ?", Time.now) }
  scope :coupon, ->  { joins("join activities on activities.id = activity_consumes.activity_id AND activities.activity_type_id = 3") }
  scope :by_activity_type, ->(activity_type_id) { joins(:activity).where('activities.activity_type_id' => activity_type_id) }

  delegate :prize, to: :activity_prize, allow_nil: true

  enum_attr :status, in: [
    ['unused', 1, '未使用'],
    ['used',   2, '已使用'],
    ['auto_used', 3, '已自动增加积分'],
    ['sended', 4, '已发放'],
    ['unsend', 5, '未发放']
  ]

  before_create :generate_code
  #after_save  :auto_use_point_prize_consume! # 自动充值积分奖

  def rqrcode
    return nil if code.blank?
    @rqrcode ||= RQRCode::QRCode.new(code, size: 4, level: :h ).to_img.resize(90, 90).to_data_url
  end

  def status_text
    if used? || mobile.present? || sended? || unsend?
      status_name
    else
      '未使用'
    end
  end

  def wx_prize_name
  end

  def wx_prize_prize_name
  end

  def mobile_status
    if mobile.present?
      if used?
        status_name
      else
        '已领取'
      end
    else
      '未领取'
    end
  end

  def use!( shop_branch = nil )
    return false if used? || auto_used?

    if activity_prize.try(:point_prize?) # 积分奖需要判断是否是会员
      vip_user = site.vip_users.normal.where(user_id: user.id).first # 避免历史数据错乱导致的不一至

      if activity_prize.try(:point_prize?) && vip_user.present? && vip_user.normal? 
        transaction do
          self.shop_branch_id = shop_branch.is_a?(ShopBranch) ? shop_branch.id : shop_branch
          self.status, self.use_at = USED, Time.now

          vip_user.increase_points!(activity_prize.points)
          vip_user.point_transactions.create!(
            direction_type: PointTransaction::ACTIVITY_PRIZE,
            points: activity_prize.points,
            site_id: site_id,
            shop_branch_id: self.shop_branch_id,
            description: '活动积分奖励',
            pointable: self
          )

          save!
        end
      else # 会员未注册或无效会员
        errors.add('积分奖充值--', '会员未注册或无效会员')
        false
      end
    elsif activity_prize.try(:redpacket_prize?)
      #先将红包奖的记录设置为已发送
      self.update_attributes(status: ActivityConsume::SENDED, use_at: Time.now)

      redis_key = "activity_consume_id_#{id}"
      jid = $redis.get(redis_key)
      Sidekiq::Status.cancel jid
      $redis.del redis_key

      red_packet = activity_prize.try(:activity_red_packet)
      return false unless red_packet
      jid = RedPacketWorker.perform_at red_packet.sidekiq_task_time.seconds.from_now, red_packet.id, user.wx_user.try(:id), id
      $redis.set(redis_key, jid, {ex: (red_packet.sidekiq_task_time + 3600)})
    else # 普通奖
      self.shop_branch_id = shop_branch.is_a?(ShopBranch) ? shop_branch.id : shop_branch
      self.status, self.use_at = USED, Time.now
      save
    end
  end

  def activity_prize_name
    "#{activity_prize.title} - #{activity_prize.prize}" if activity_prize
  end

  def activity_or_coupon_name
    activity_name
  end

  def used_at
    use_at
  end

  def expired_at
    use_at
  end

  def unexpired?
    expired_at.nil? || expired_at > Time.now
  end

  def expired?
    !unexpired? && unused?
  end

  def can_use?
    unexpired? && unused?
  end

   def link_class
    if can_use?
      "c-use"
    elsif used?
      "c-used"
    elsif expired?
      "c-overdue"
    end
  end

  def activity_or_coupon_info
    activity_prize.try(:prize)
  end

  def mobile_or_vip_mobile
    mobile || vip_mobile
  end

  def vip_user
    user.try(:vip_user)
  end

  def vip_mobile
    vip_user.try(:mobile)
  end

  def activity_name
    activity.try(:name)
  end

  def shop_branch_name
    shop_branch.try(:name) || '商户总部'
  end

  def sn_code_type_name
    "奖品券"
  end

  def name
    activity_prize.prize
  end

  def user_type
    "User"
  end

  def user_name
    user.wx_user.nickname
  end

  def shop_branch_count
    nil
  end

  def validate_shop_branchs(shop_branch_id)
    true
  end

  def use_consume(shop_branch)
    if vip_privilege && user
      vip_user = site.vip_users.visible.where(user_id: user_id).first
      return false if vip_user.blank? || vip_user.freeze? || !@activity_consume.vip_privilege.pending? || @activity_consume.vip_privilege.privilege_status != VipPrivilege::STARTED
    end
    use!(shop_branch)
  end

  def activity_group_name
    activity_group.try(:name)
  end  

  def activity_group_qty
    activity_group.try(:item_qty)   
  end  

  def auto_use_point_prize_consume!
    return false if used? || auto_used?

    if activity_prize.try(:point_prize?) # 积分奖需要判断是否是会员
      vip_user = site.vip_users.normal.where(user_id: user.id).first # 避免历史数据错乱导致的不一至

      if activity_prize.try(:point_prize?) && vip_user.present? && vip_user.normal? 
        transaction do
          #self.shop_branch_id = shop_branch.is_a?(ShopBranch) ? shop_branch.id : shop_branch
          self.status, self.use_at = AUTO_USED, Time.now
          vip_user.increase_points!(activity_prize.points)
          vip_user.point_transactions.create!(
            direction_type: PointTransaction::ACTIVITY_PRIZE,
            points: activity_prize.points,
            site_id: site_id,
            description: '活动积分奖励',
            pointable: self
          )

          save!
        end
      else # 会员未注册或无效会员
        errors.add('积分奖充值--', '会员未注册或无效会员')
        false
      end
    elsif activity_prize.try(:redpacket_prize?)
      #先将红包奖的记录设置为已发送
      self.update_attributes(status: ActivityConsume::SENDED, use_at: Time.now)

      red_packet = activity_prize.try(:activity_red_packet)
      retrun false unless red_packet

      redis_key = "activity_consume_id_#{id}"
      jid = RedPacketWorker.perform_at red_packet.sidekiq_task_time.seconds.from_now, red_packet.id, user.wx_user.try(:id), id
      $redis.set(redis_key, jid, {ex: (red_packet.sidekiq_task_time + 3600)})
    end
  end

  private
    def generate_code
      self.code = ::SnCodeGenerator.generate_code(self)
    end
end
