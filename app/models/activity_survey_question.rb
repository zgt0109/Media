# == Schema Information
#
# Table name: activity_survey_questions
#
#  id           :integer          not null, primary key
#  activity_id  :integer
#  name         :string(255)
#  limit_select :integer          default(1), not null
#  answer_a     :string(255)
#  answer_b     :string(255)
#  answer_c     :string(255)
#  answer_d     :string(255)
#  answer_e     :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ActivitySurveyQuestion < ActiveRecord::Base
  belongs_to :activity
  # attr_accessible :answer_a, :answer_b, :answer_c, :answer_d, :answer_e, :name
  # validates :answer_a, :answer_b, presence: true
  validates :name, presence: true

  has_many :activity_survey_answers, dependent: :destroy
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
    finshed_activity_survey_answers.where(conditions).count
  end

  def finshed_activity_survey_answers
    activity_survey_answers.joins(:activity_user).where("activity_users.status = ? ", ActivityUser::SURVEY_FINISH)
  end

  def total_user
    finshed_activity_survey_answers.group(:activity_user_id).count
  end

  def per answer
    finshed_activity_survey_answers.count == 0 ? 0 : Float(selected_count answer) / Float(finshed_activity_survey_answers.count) * 100
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
    @activity_questions_ids ||= activity.activity_survey_questions.order(:position).pluck(:id)
  end

  def choices_ids
    @choices_ids ||= survey_question_choices.order(:position).pluck(:id)
  end

  private

    def set_position
      self.position = activity.activity_survey_questions.maximum('position').to_i + 1
    end

end
