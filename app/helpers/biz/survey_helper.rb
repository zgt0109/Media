module Biz::SurveyHelper
  def survey_answer(answer)
    answer == '其他' ? '其他' : "选项#{answer}"
  end
end