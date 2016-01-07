# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  match_type    :integer          default(1), not null
#  ask           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Question < ActiveRecord::Base
  validates :ask, :wx_mp_user_id, :supplier_id, presence: true
  validates :ask, uniqueness: { scope: :wx_mp_user_id, case_sensitive: false }

  belongs_to :wx_mp_user
  belongs_to :supplier
  has_one :answer, dependent: :destroy
  accepts_nested_attributes_for :answer

  acts_as_enum :match_type, :in => [
      ['full_match',  1, '全匹配'],
      ['fuzzy_match', 2, '模糊匹配']
  ]

  def self.search_keyword(keyword)
    keyword = keyword.to_s.downcase
    question = where('lower(questions.ask) = ?', keyword).first
    return question if question.present?

    # 先进行模糊匹配，再进行反向模糊匹配
    questions = fuzzy_match.where('lower(questions.ask) like ?', "%#{keyword}%").to_a
    questions = fuzzy_match.where("? like CONCAT('%', questions.ask, '%')", keyword).to_a if questions.size == 0
    questions_count = questions.size

    return questions[rand(questions_count)] if questions_count > 0
  end

  def reply_type_text
    answer.answer_type_name rescue ''
  end
end
