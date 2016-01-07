class Kf::Account < ActiveRecord::Base
  # self.table_name = 'accounts'
  # establish_connection "kefu_app_#{Rails.env}"

  has_many :staffs, class_name: 'Kf::Staff'
end

