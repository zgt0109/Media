class ActivityFeedback < ActiveRecord::Base
  belongs_to :activity
  belongs_to :user
  belongs_to :activity_user
end
