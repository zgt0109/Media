class Brokerage::ClientChange < ActiveRecord::Base
  belongs_to :client
  belongs_to :commission_type
  belongs_to :old_commission_type, class_name: 'Brokerage::CommissionType'
  belongs_to :commission_transaction
end
