# == Schema Information
#
# Table name: fight_answers
#
#  id                      :integer          not null, primary key
#  wx_mp_user_id           :integer          not null
#  wx_user_id              :integer          not null
#  activity_id             :integer          not null
#  fight_paper_question_id :integer          not null
#  the_day                 :integer          not null
#  user_answer             :string(255)
#  correct_answer          :string(255)      not null
#  score                   :integer          default(0), not null
#  speed                   :integer          default(20), not null
#  status                  :integer          default(0), not null
#  description             :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class FightAnswer < ActiveRecord::Base
  #attr_accessible :activity_id, :correct_answer, :description, :fight_paper_question_id, :score, :speed, :status, :user_answer, :wx_mp_user_id, :wx_user_id
  belongs_to :fight_paper_question
  belongs_to :activity
  belongs_to :wx_user
  
end
