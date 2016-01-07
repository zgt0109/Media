module Concerns::Brokerages
  extend ActiveSupport::Concern

  included do
    has_one :brokerage_activity, class_name: 'Activity', conditions: { activity_type_id: ActivityType::BROKERAGE }

    has_many :brokerage_brokers, class_name: '::Brokerage::Broker'
    has_many :brokerage_clients, class_name: '::Brokerage::Client', through: :brokerage_brokers, source: :clients
    has_many :brokerage_client_changes, class_name: '::Brokerage::ClientChange', through: :brokerage_clients, source: :client_changes
    has_many :brokerage_commission_transactions, class_name: '::Brokerage::CommissionTransaction', through: :brokerage_brokers, source: :commission_transactions
    has_many :brokerage_commission_types, class_name: '::Brokerage::CommissionType', through: :brokerage_activity

    def brokerage_setting
      brokerage_activity.try(:activityable)
    end
  end
end
