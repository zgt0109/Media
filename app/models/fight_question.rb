# == Schema Information
#
# Table name: fight_questions
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  wx_mp_user_id  :integer          not null
#  title          :string(255)      not null
#  answer_a       :string(255)      not null
#  answer_b       :string(255)      not null
#  answer_c       :string(255)
#  answer_d       :string(255)
#  answer_e       :string(255)
#  correct_answer :string(255)      not null
#  status         :integer          default(1), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FightQuestion < Activity::Question
  default_scope -> { where(activity_type_id: ActivityType::FIGHT) }

  has_many :fight_paper_questions
  has_many :fight_papers, through: :fight_paper_questions
end
