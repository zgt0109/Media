class Guess::ActivityQuestion < ActiveRecord::Base
  belongs_to :activity
  belongs_to :question

  has_many :participations
  has_many :consumes, through: :participations

  validates :question_id, presence: true
  validates :activity_id, presence: true
  scope :visible, -> { where(visible: true)}

  def question_answer_limit
    activity.guess_setting.question_answer_limit
  end

  def consumes_count
    consumes.today.count
  end

  def over?
    consumes_count >= question_answer_limit
  end
end
