class VipMessagePlan < ActiveRecord::Base
  belongs_to :vip_card
  include Concerns::VipGivenGroupable

  attr_accessor :skip_validate_send_at

  enum_attr :status, in: [
    ['unsent', 1, '未发送'],
    ['sent',   2, '已发送']
  ]

  validates :title, :content, presence: true
  validate :send_at_must_greater_than_now, if: :send_at?
  before_create :save_scheduled

  def scheduled_name
    scheduled? ? '定时发送' : '立即发送'
  end

  def wx_mp_user
    vip_card.site.wx_mp_user
  end

  alias receivers group_receivers

  def save_scheduled
    self.scheduled = send_at.present?
    true
  end

  private
  def send_at_must_greater_than_now
    return if skip_validate_send_at || send_at.blank?

    if send_at < Time.now
      errors.add(:send_at, '不能小于当前时间')
    end
  end

end
