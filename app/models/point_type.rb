class PointType < ActiveRecord::Base
  belongs_to :site
  has_many   :point_transactions

  scope :greatest, -> { order('amount DESC') }

  validates :amount, presence: true, numericality: { greater_than: 0 }, if: :consume_or_recharge?
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 1, less_than: 10000000 }
  validates :succ_checkin_points, :succ_checkin_days, presence: true, numericality: { greater_than_or_equal_to: 1 }, if: :succ_checkin_enabled?
  # validates  :amount, uniqueness: {:scope => [:site_id, :category], message: '该金额已存在' }
  validate :amount_exist?

  enum_attr :status, :in => [
    ['normal',  1, '正常'],
    ['stopped', 2, '停用'],
  ]
  enum_attr :category, :in => [
    ['consume',   1, '消费送积分'],
    ['recharge',  2, '充值送积分'],
    ['checkin',   3, '签到送积分'],
    ['register',  4, '领卡送积分']
  ]

  before_save { self.points ||= 0 }

  def amount_exist?
    point_type = PointType.normal.where(site_id: site_id, category: category, amount: amount).find do |point_type|
      id.presence != point_type.id
    end
    if point_type.present?
      errors.add(:amount, '该金额已存在')
    end
  end

  def consume_or_recharge?
    consume? || recharge?
  end

end
