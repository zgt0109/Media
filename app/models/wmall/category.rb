class Wmall::Category < ActiveRecord::Base
  belongs_to :mall

  validates_presence_of :name
end
