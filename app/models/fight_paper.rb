class FightPaper < ActiveRecord::Base

  belongs_to :activity
  has_many :fight_paper_questions
  has_many :fight_questions, through: :fight_paper_questions
  has_many :fight_answers, through: :fight_paper_questions

  validates :read_time, presence: true, numericality: { greater_than_or_equal_to: 10, less_than_or_equal_to: 60 }, on: :update

  def self.batch_update!(fight_papers, params)
    return false if params.blank?
    transaction do
      fight_papers.first.activity.update_attributes(status: Activity::SETTED) if fight_papers.first.activity.setting?
      fight_papers.each do |fight_paper|
        if params[:description].present? and params[:read_time].present?
          fight_paper.update_attributes(description: params[:description]["#{fight_paper.the_day}"][0], read_time: params[:read_time]["#{fight_paper.the_day}"][0], fight_question_ids: params[:fight_question]["#{fight_paper.the_day}"])
        end
      end
    end
    return true
  end

  def fight_questions_with_default
    fight_questions.present? ? fight_questions : Array.new(5) { FightQuestion.new }
  end

end
