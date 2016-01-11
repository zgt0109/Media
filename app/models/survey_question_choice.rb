class SurveyQuestionChoice < ActiveRecord::Base
  belongs_to :survey_question

  before_destroy :destroy_survey_answers

  def pic_url
  	qiniu_image_url(self['pic_key'])
  end

  def destroy_survey_answers
    index = survey_question.survey_question_choice_ids.index(id) + 3
    survey_question.survey_answers.where(answer: index).delete_all
    survey_question.survey_answers.where("answer > #{index} AND answer != '其他'").update_all("answer = answer - 1")
  end

end
