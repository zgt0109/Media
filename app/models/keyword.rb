class Keyword < ActiveRecord::Base
  validates :name, :site_id, presence: true
  validates :name, uniqueness: { scope: :site_id, case_sensitive: false }

  belongs_to :site
  has_one :reply, as: :replier, dependent: :destroy
  accepts_nested_attributes_for :reply

  acts_as_enum :match_type, :in => [
    ['full_match',  1, '全匹配'],
    ['fuzzy_match', 2, '模糊匹配']
  ]

  acts_as_enum :msg_type, :in => [
    ['keyword_reply', 1, '关键词回复'],
    ['subscribe', 2, '关注事件'],
    ['autoreply', 3, '自动回复']
  ]

  def self.search_keyword(keyword)
    keyword = keyword.to_s.downcase
    question = where('lower(keywords.name) = ?', keyword).first
    return question if question.present?

    # 先进行模糊匹配，再进行反向模糊匹配
    questions = fuzzy_match.where('lower(keywords.name) like ?', "%#{keyword}%").to_a
    questions = fuzzy_match.where("? like CONCAT('%', keywords.name, '%')", keyword).to_a if questions.count == 0
    questions_count = questions.count

    return questions[rand(questions_count)] if questions_count > 0
  end

  def reply_type_text
    reply.reply_type_name rescue ''
  end
end
