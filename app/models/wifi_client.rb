class WifiClient < ActiveRecord::Base
  belongs_to :supplier
  has_many :activities, as: :activityable
  accepts_nested_attributes_for :activities
  # attr_accessible :ip_address, :is_login_join, :mobile
end
