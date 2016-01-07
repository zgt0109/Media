# == Schema Information
#
# Table name: fight_paper_questions
#
#  id                :integer          not null, primary key
#  fight_paper_id    :integer          not null
#  fight_question_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class FightPaperQuestion < ActiveRecord::Base
  # attr_accessible :fight_paper_id, :fight_question_id
  belongs_to :fight_paper
  belongs_to :fight_question, foreign_key: 'fight_question_id'
  has_many :fight_answers

end
