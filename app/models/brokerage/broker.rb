class Brokerage::Broker < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_user
  has_many :clients
  has_many :commission_transactions
  has_many :unsettled_client_changes, through: :clients, source: :client_changes, conditions: { commission_transaction_id: nil }

  validates :supplier_id, :wx_user_id, :name, :mobile, presence: true
  validates :bank_account_name, :bank_card_no, :bank_name, presence: true, if: :update_and_bank_card?
  validates :alipay_account_name, :alipay_receiver, presence: true, if: :alipay?

  acts_as_enum :settlement_type, in: [
    ['bank_card', 1, '银行卡绑定'],
    ['alipay',    2, '支付宝绑定']
  ]

  # 经纪人结算方法，结算步骤：
  # 1、将已算金额设置为：原已结算金额 + 原未结算金额
  # 2、将原未结算金额清零
  # 3、生成一条佣金结算事务记录，保存1、2步的结算金额和结算后账户的已结算金额
  # 4、将该经纪人未结算的客户状态修改的记录关联到第3步生成的佣金结算事务记录
  def settle_commission!
    #errors.add(:base, '未结佣金必须大于0') and return false if unsettled_commission <= 0
    errors.add(:base, '未结佣金不能小于最低结算金额') and return false if unsettled_commission < supplier.brokerage_setting.min_settlement_amount

    transaction do
      old_unsettled_commission = unsettled_commission
      update_attributes!(settled_commission: settled_commission + old_unsettled_commission, unsettled_commission: 0)
      commission_transaction = commission_transactions.create!(commission: old_unsettled_commission, settled_commission: settled_commission)
      unsettled_client_changes.each do |client_change|
        client_change.update_attributes!(commission_transaction_id: commission_transaction.id)
      end
    end
  end

  def total_commission
    settled_commission + unsettled_commission
  end

  def update_and_bank_card?
    persisted? && bank_card?
  end
end
