class FightQuestion < Activity::Question
  default_scope -> { where(activity_type_id: ActivityType::FIGHT) }

  has_many :fight_paper_questions
  has_many :fight_papers, through: :fight_paper_questions
end
