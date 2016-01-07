class Guess::Question < Activity::Question
  default_scope -> { where(activity_type_id: ActivityType::GUESS) }
  has_many :activity_questions
  has_many :activities, through: :activity_questions

  def answers
    arr = [['A', answer_a], ['B', answer_b], ['C', answer_c], ['D', answer_d], ['E', answer_e]].shuffle
    Hash[arr].reject{|key, value| value.blank? }
  end
end
