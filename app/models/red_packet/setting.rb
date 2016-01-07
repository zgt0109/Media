class RedPacket::Setting < ActiveRecord::Base
  validates :packet_num, :amount, :start_at, :end_at, presence: true
  validates :packet_num, numericality: {greater_than_or_equal_to: -1, only_integer: true}
  validates :amount, numericality: {greater_than_or_equal_to: 1, only_integer: true}
  validate :end_at_greater_than_start_at

  has_one :activity, as: :activityable, conditions: { activity_type_id: ActivityType::RED_PACKET }
  accepts_nested_attributes_for :activity

  delegate :name, :keyword, :summary, :starting?, to: :activity, allow_nil: true

  def sn_time?
    end_at < Time.now || start_at > Time.now
  end

  def mark_delete!
    activity.update_column(:status, Activity::DELETED) if activity
  end

  def end_at_greater_than_start_at
    self.errors.add(:end_at, '不能小于开始时间') if start_at && end_at && end_at <= start_at
  end

  def generate_award_amount
    amount_random? ? rand(1..amount.to_i) : amount
  end
end
