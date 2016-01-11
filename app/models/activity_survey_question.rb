class SurveyQuestion < ActiveRecord::Base

  validates :name, presence: true

  belongs_to :activity

  has_many :survey_answers, dependent: :destroy
  has_many :survey_question_choices, dependent: :destroy
  accepts_nested_attributes_for :survey_question_choices, allow_destroy: true

  acts_as_list scope: :activity_id

  enum_attr :survey_question_type, :in => [
    ['text', 1, '文字形式'],
    ['text_picture', 2, '图文形式'],
    ['picture', 3, '图片形式'],
  ]

  before_create :set_position

  def selected_count answer
    conditions = answer == '其他' ? ['answer = ?', answer] : ['survey_question_choice_id = ?', answer.id]
    finshed_survey_answers.where(conditions).count
  end

  def finshed_survey_answers
    survey_answers.joins(:activity_user).where("activity_users.status = ? ", ActivityUser::SURVEY_FINISH)
  end

  def total_user
    finshed_survey_answers.group(:activity_user_id).count
  end

  def per answer
    finshed_survey_answers.count == 0 ? 0 : Float(selected_count answer) / Float(finshed_survey_answers.count) * 100
  end

  def activity_index #在活动中的顺序
    activity_questions_ids.index(id)
  end

  def activity_progess #在活动中的顺序
    activity_questions_ids.index(id) + 1
  end

  def has_next?
    !last? && activity_questions_ids_more_than_one?
  end

  def has_prev?
    !first? && activity_questions_ids_more_than_one?
  end

  def first?
    id == activity_questions_ids.first
  end

  def last?
    id == activity_questions_ids.last
  end

  def next_question_id
    activity_questions_ids[activity_index + 1]
  end

  def prev_question_id
    activity_questions_ids[activity_index - 1]
  end

  def activity_questions_ids_more_than_one?
    activity_questions_ids.count > 1
  end

  def activity_questions_ids
    @activity_questions_ids ||= activity.survey_questions.order(:position).pluck(:id)
  end

  def choices_ids
    @choices_ids ||= survey_question_choices.order(:position).pluck(:id)
  end

  private

    def set_position
      self.position = activity.survey_questions.maximum('position').to_i + 1
    end

end
