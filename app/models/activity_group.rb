class ActivityGroup < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user

  has_many :activity_consumes
end
