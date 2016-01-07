# == Schema Information
#
# Table name: activity_survey_answers
#
#  id                          :integer          not null, primary key
#  activity_id                 :integer
#  activity_user_id            :integer
#  activity_survey_question_id :integer
#  wx_user_id                  :integer
#  answer                      :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class ActivitySurveyAnswer < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :activity_user
  belongs_to :activity_survey_question

  # def self.create_user_answer(user_answer, attrs)
  #   ActivitySurveyAnswer.where(user_answer).first_or_create(attrs)
  # end

end
