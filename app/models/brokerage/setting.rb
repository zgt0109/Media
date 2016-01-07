class Brokerage::Setting < ActiveRecord::Base
  has_one :activity, as: :activityable, conditions: { activity_type_id: ActivityType::BROKERAGE }

  accepts_nested_attributes_for :activity

  validates :agreement, :tel, :month_settlement_day, :min_settlement_amount, presence: true
  validates :min_settlement_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :month_settlement_day, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }

  after_create :create_commission_types

  def logo_url
    qiniu_image_url(logo_key) || "/assets/mobile/brokerage/banner.png"
  end

  def pic_url
    qiniu_image_url(pic_keys) || "/assets/mobile/brokerage/index-banner.png"
  end

  def create_commission_types
  	Brokerage::CommissionType.mission_type_options.each do |type|
      type_status = type.first == "新客户" ? Brokerage::CommissionType::ENABLED : Brokerage::CommissionType::DISABLED
	  	Brokerage::CommissionType.create(activity_id: activity.id, mission_type: type.last, commission_type: Brokerage::CommissionType::READY_MONEY, status: type_status)
	  end
  end
end
