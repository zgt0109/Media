class FightPaperQuestion < ActiveRecord::Base
  belongs_to :fight_paper
  belongs_to :fight_question, foreign_key: 'fight_question_id'
  has_many :fight_answers

end
