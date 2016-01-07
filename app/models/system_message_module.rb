class SystemMessageModule < ActiveRecord::Base
  has_many :system_messages
  has_many :system_message_settings
end