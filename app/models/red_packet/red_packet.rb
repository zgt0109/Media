class RedPacket::RedPacket < ActiveRecord::Base
  self.table_name = :red_packets

  belongs_to :activity
  belongs_to :supplier
  belongs_to :payment_type
  belongs_to :activity_prize
  has_many   :send_records, class_name: RedPacket::SendRecord
  has_one    :consume, as: :consumable

  validates :nick_name, :send_name, presence: true, length: { maximum: 32 }
  validates :act_name, :total_amount, :total_num, :min_value, :max_value, :total_budget, presence: true
  validates_numericality_of :min_value, :max_value, greater_than_or_equal_to: 1, less_than_or_equal_to: 200
  validates_numericality_of :total_budget, greater_than_or_equal_to: 1
  validates :wishing, :remark, presence: true
  validates :send_at, presence: true
  #validates_uniqueness_of :act_name, scope: :supplier_id, conditions: -> { where(status: RedPacket::RedPacket::NORMAL) } 
  # validate  :act_name_uniqueness_validate
  
  scope     :visible, -> { where(status: RedPacket::RedPacket::NORMAL) }

  enum_attr :receive_type, :in => [
    ['follow',   0, '关注'],
    ['all_fans', 1, '所有粉丝'],
    ['all_vips', 2, '所有会员'],
    ['uid',      3, '指定用户'],
    ['group',    4, '用户组'],
  ]

  enum_attr :status, in: [
      ["deleted", -1, "已删除"],
      ['normal', 1, "有效"],
      ['disabled', 2, "无效"]
  ]

  enum_attr :payment_type_id, :in => PaymentType::ENUM_ID_OPTIONS

  def can_send_redpacket?
    total_amount <= budget_balance
  end

  def sent?(uid)
    send_rec = self.send_records.where(uid: uid).first 

    send_rec.present? && !send_rec.ready? && !send_rec.failed? 
  end

  def set_budget_balance(before_total_budget)
    if total_budget >= before_total_budget
       balance = total_budget - before_total_budget
      self.budget_balance += balance
    else
      balance = before_total_budget - total_budget
      if budget_balance >= balance
        self.budget_balance =  budget_balance - balance
      else
        self.budget_balance = 0
      end
    end
  end

  def sidekiq_task_time
    [(send_at - Time.now).to_i, 0 ].max
  end

  #将所有的红包的nick_name和send_name设置成商户公众号的昵称
  def self.update_red_packet_nick_and_send_name
    pp '--------------update all start'
    RedPacket::RedPacket.transaction do
      Supplier.all.each do |s|
        pp "===============supplier_id   #{s.id}"
        next if s.red_packets.length < 1
        s.red_packets.update_all(nick_name: s.wx_mp_user.try(:name), send_name: s.wx_mp_user.try(:name))
      end
      pp '============ update all end'
    end
  end

  private

  def act_name_uniqueness_validate
    if self.new_record?
      packet = RedPacket::RedPacket.where("act_name = ? and supplier_id = ? and status = #{RedPacket::RedPacket::NORMAL}", act_name, supplier_id)
    else
      packet = RedPacket::RedPacket.where("act_name = ? and supplier_id = ? and id != ? and status = #{RedPacket::RedPacket::NORMAL}", act_name, supplier_id, self.id)
    end

    if packet.present?
      errors.add(:act_name, I18n.t("activerecord.errors.messages.taken"))
    end
  end
end
