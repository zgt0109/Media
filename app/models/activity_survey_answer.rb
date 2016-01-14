class SurveyAnswer < ActiveRecord::Base

  belongs_to :activity_user
  belongs_to :survey_question

end
