class Activity::GuessActivity < Activity
  has_one :guess_setting, class_name: 'Guess::Setting', foreign_key: 'activity_id'
  default_scope -> { where(activity_type_id: ActivityType::GUESS) }

  has_many :guess_activity_questions, class_name: 'Guess::ActivityQuestion', foreign_key: 'activity_id'
  has_many :questions, through: :guess_activity_questions, class_name: 'Guess::Question'

  has_many :participations, class_name: 'Guess::Participation', foreign_key: 'activity_id'
  has_many :guess_consumes, through: :participations, source: :consume

  # select * from consumes join guess_participations on guess_participations.consume_id = consumes.id join activities on guess_participations.activity_id = activities.id where activities.activity_type_id = ActivityType::GUESS;

  delegate :use_points?, :answer_points, :wx_user?, :vip_user?, :question_answer_limit, to: :guess_setting, allow_nil: true

  def underway?
    setted? && activity_status == Activity::UNDER_WAY
  end

  def insufficient_points_for?(vip_user)
    use_points? && vip_user.usable_points < answer_points
  end

  def guess_consumes_max_count
    duration_days * guess_consumes_day_count
  end

  def guess_consumes_day_count
    questions.count * question_answer_limit.try(:to_i)
  end

end
