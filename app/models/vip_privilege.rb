# == Schema Information
#
# Table name: vip_privileges
#
#  id              :integer          not null, primary key
#  vip_card_id     :integer          not null
#  title           :string(255)      not null
#  content         :text             default(""), not null
#  limit_count     :integer          default(-1), not null
#  day_limit_count :integer          default(-1), not null
#  start_date      :date             not null
#  end_date        :date             not null
#  status          :integer          default(0), not null
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class VipPrivilege < ActiveRecord::Base
  READY = 0; STARTED = 1; ENDED = 2;
  READY_NAME = '未开始'; STARTED_NAME = '进行中'; ENDED_NAME = '已结束';

  belongs_to :vip_card
  has_many :activity_consumes
  has_many :vip_user_transactions, as: :transactionable
  has_many :vip_privilege_transactions, dependent: :destroy
  has_many :point_transactions, as: :pointable
  has_and_belongs_to_many :vip_grades, conditions: "vip_grades.status IN(0,1)", uniq: true

  validates :title, presence: true, length: { maximum: 30, message: '标题过长' }
  # validates :content, presence: true, length: { maximum: 500, message: '内容过长' }
  validates :amount, presence: true, :numericality => { greater_than: 0 }, if: :discount?
  validates :value, presence: true, :numericality => { greater_than: 0 }
  validates :value, presence: true, :numericality => { greater_than: 0, less_than: 10, message: '必须大于0并且小于10' }, if: :discount?
  validates :limit_count, presence: true, :numericality => { greater_than_or_equal_to: -1 }
  validates :start_date, :end_date, presence: true, unless: :always_valid?
  validate :validate_vip_grade
  scope :normal_grade, -> { where(normal_grade: true) }
  scope :greatest, -> { order('amount DESC') }
  scope :greatest_value, -> { order('value DESC') }
  scope :unexpired, -> { where('always_valid = 1 OR (? BETWEEN start_date AND end_date)', Date.today) }

  enum_attr :category, :in => [
    ['consume',  1, '消费享特权'],
    ['recharge', 2, '充值享特权']
  ]

  enum_attr :value_by, :in => [
    ['point',    1, '享受积分'],
    ['discount', 2, '享受折扣'],
    ['money',    3, '享受送现金']
  ]

  enum_attr :status, :in => [
    ['completed',  2, '已结束'],
    ['active',     1, '进行中'],
    ['pending',    0, '未开始'],
    ['stopped',   -1, '已停用'],
    ['deleted',   -2, '已删除']
  ]

  scope :show, -> { where('vip_privileges.status >= ?', -1) }
  scope :active_for, proc { |date| where(status: [0 ,1]).where(':date BETWEEN vip_privileges.start_date AND vip_privileges.end_date', date: date) }
  scope :not_deteled, proc { where(status: [0, 1, 2]) }
  scope :underway, -> { where( "always_valid = ? OR (? BETWEEN start_date AND end_date)", true, Date.today ) }
  scope :money_greater_than, ->(amount) { where( "amount <= ?", amount ) }
  scope :show_value_by, -> { where( value_by: [DISCOUNT ,MONEY] ) }

  def start?
    start_date <= Date.today
  end

  def underway?
    Date.today >= start_date && Date.today <= end_date
  end

  def recharge_name
    if discount?
      new_amount = sprintf("%.2f",amount.round(2))
      "充值#{new_amount}元以上享#{value}折"
    elsif money?
      new_amount = sprintf("%.2f",amount.round(2))
      "充值#{new_amount}元以上赠送#{value}元"
    elsif point?
      "充值享#{value}倍积分"
    end
  end

  def consume_name
    if discount?
      new_amount = sprintf("%.2f",amount.round(2))
      "消费#{new_amount}元以上享#{value}折"
    else
      "消费享#{value}倍积分"
    end
  end

  def transaction_name
    recharge? ? recharge_name : consume_name
  end

  def privilege
    if point?
      privilege = vip_card.supplier.point_types.normal.where(category: category).map do |pt|
        "#{pt.category_name[0, 2]}#{pt.amount}元送#{value.to_i * pt.points}积分"
      end.join("、").presence
    end
    privilege || transaction_name
  end

  def privilege_json
    { title: title, privilege: privilege, content: content, category: category, amount: amount, value_by: value_by, value: value }
  end


  def privilege_status
    now = Date.today
    if now < start_date
      READY
    elsif now >= start_date and now <= end_date
      STARTED
    else
      ENDED
    end
  end

  def end_date_must_after_start_date
    return true if always_valid?
    if new_record? and start_date <= Date.today
      errors.add(:start_date, '起始时间必须大于当前时间')
    end
    if start_date >= end_date
      errors.add(:end_date, '结束时间必须大于起始时间')
    end
  end

  def privilege_status_name
    now = Date.today
    if now < start_date
      READY_NAME
    elsif now >= start_date and now <= end_date
      STARTED_NAME
    else
      ENDED_NAME
    end
  end

  def del!
    update_attributes(status: DELETED)
  end

  def stop!
    update_attributes!(status: STOPPED)
  end

  def all_grades?
    vip_card.vip_grades.visible.count == vip_grades.visible.count
  end

  def vip_grade_names
    return '所有会员' if all_grades?
    vip_grades.visible.sorted.pluck(:name).join("、")
  end

  def self.transaction_names_by_category(category)
    return [] if category !~ /\Aconsume|recharge\z/
    public_send(category).map {|x|[x.id, x.transaction_name]}
  end

  def limited?( vip_user )
    if point?
      !point_unlimited?(vip_user)
    elsif discount?
      !discount_unlimited?(vip_user)
    end
  end

  def limit_count_for( vip_user )
    return '不限' if limit_count == -1
    num = limit_count - if point?
      point_transactions.where(vip_user_id: vip_user.id).count
    else
      vip_user_transactions.where(vip_user_id: vip_user.id).count
    end

    num < 0 ? 0 : num
  end

  def point_unlimited?( vip_user )
    return true if limit_count == -1

    limit_count > point_transactions.where(vip_user_id: vip_user.id).count
  end

  def discount_unlimited?( vip_user )
    return true if limit_count == -1

    if consume?
      limit_count > vip_user_transactions.where(vip_user_id: vip_user.id).count
    else
      limit_count > vip_privilege_transactions.where(vip_user_id: vip_user.id).count
    end
  end

  def validate_vip_grade
    vip_grade = vip_card.vip_privileges.where(category: category, amount: amount, value_by: value_by, status: [0,1]).find do |privilege|
      vip_grade_ids == privilege.vip_grade_ids && id != privilege.id
    end
    errors.add(:vip_grade, '同类型同等级的特权已存在') if vip_grade
  end

end
