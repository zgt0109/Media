class Brokerage::CommissionTransaction < ActiveRecord::Base
  belongs_to :broker
  has_many :client_changes
end
