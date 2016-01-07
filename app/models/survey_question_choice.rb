class SurveyQuestionChoice < ActiveRecord::Base
  belongs_to :activity_survey_question

  before_destroy :destroy_activity_survey_answers

  def pic
  	qiniu_image_url(self['pic'])
  end

  def destroy_activity_survey_answers
    index = activity_survey_question.survey_question_choice_ids.index(id) + 3
    activity_survey_question.activity_survey_answers.where(answer: index).delete_all
    activity_survey_question.activity_survey_answers.where("answer > #{index} AND answer != '其他'").update_all("answer = answer - 1")
  end

end
