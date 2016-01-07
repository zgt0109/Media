# == Schema Information
#
# Table name: activity_feedbacks
#
#  id               :integer          not null, primary key
#  activity_id      :integer          not null
#  activity_user_id :integer
#  wx_user_id       :integer          not null
#  feedback_type    :integer          default(1), not null
#  status           :integer          default(1), not null
#  content          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ActivityFeedback < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :activity
  belongs_to :wx_user
  belongs_to :activity_user
end
