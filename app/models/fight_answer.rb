class FightAnswer < ActiveRecord::Base
  belongs_to :fight_paper_question
  belongs_to :activity
  belongs_to :user
end
