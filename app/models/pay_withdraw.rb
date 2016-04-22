class PayWithdraw < ActiveRecord::Base
  belongs_to :pay_account

  before_create :generate_trade_no, :generate_default_attributes

  enum_attr :status, :in => [
    ['pending',  0, '待处理'],
    ['success',    1, '提现成功'],
    ['failure',   -1, '提现失败']
  ]

  def self.fee(amount)
    service_charge = if amount < 10000
      5.00
    elsif amount < 100000
      10.00
    elsif amount < 500000
      15.00
    elsif amount < 1000000
      20.00
    elsif amount >= 1000000
      amount * 0.00002
    else
      0.00
    end
    service_charge = 200.00 if service_charge > 200.00
    service_charge.to_f.round(2)
  end

  private
    def generate_default_attributes
      self.bank_name = pay_account.bank_name
      self.bank_branch = pay_account.bank_branch
      self.bank_name = pay_account.bank_name
      self.bank_account = pay_account.bank_account
    end

    def generate_trade_no
      self.trade_no = Time.now.to_formatted_s(:number).to_s  + SecureRandom.hex.first(3)
    end
end
