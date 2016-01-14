class DonationOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :donation
  # attr_accessible :body, :fee, :paid_at, :pay_info, :state, :subject, :trade_no, :trade_state, :transaction_id
  validates :fee, :numericality => {:greater_than => 0}

  enum_attr :state, :in => [
    ['pending',   1, '未付款'],
    ['paid',      2, '已付款'],
    ['confirmed', 3, '已确认']
  ]

  before_create :add_default_attrs

  def pay!
    update_column("state", 2)
  end

  def cancel!
    update_column("state", 1)
  end

  def donation_name
    self.donation.name
  end

  def add_default_attrs
    now = Time.now
    self.trade_no = [now.strftime('%Y%m%d'), now.usec.to_s.ljust(6, '0')].join
    self.site_id = self.donation.try(:site_id)
  end
end
