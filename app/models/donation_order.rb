class DonationOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :donation

  validates :fee, :numericality => {:greater_than => 0}

  enum_attr :status, :in => [
    ['pending',   0, '未付款'],
    ['paid',      1, '已付款'],
    ['confirmed', 2, '已确认']
  ]

  before_create :add_default_attrs

  def pay!
    update_column("status", 1)
  end

  def cancel!
    update_column("status", 2)
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
