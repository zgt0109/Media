class Guess::Participation < ActiveRecord::Base
  belongs_to :activity_question
  belongs_to :activity
  belongs_to :question
  belongs_to :activity_user
  belongs_to :user

  has_one :consume, as: :consumable

  scope :today, -> { where("date(guess_participations.created_at) = ?", Date.today) }
  scope :answer_correct, -> { where(answer_correct: true) }

  def check_correct(user)
    if question.correct_answer == answer
      self.answer_correct = true
      coupon = activity.guess_setting.prize
      consume = user.consumes.create(
        site_id: user.site_id,
        consumable:    coupon,
        expired_at:    coupon.use_end
      )
      self.consume_id = consume.id
    else
      self.answer_correct = false
    end
    self.save
    answer_correct
  end
end
