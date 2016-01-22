class ActivityProperty < ActiveRecord::Base

  store :meta, accessors: [ :no_prize_title, :consume_day_allow_count ], coder: JSON

  validates :item_name, length: { maximum: 10 }, presence: true, on: :update, if: :groups?
  validates :special_warn, length: { maximum: 2000 }, presence: true, if: :fight?
  validates_numericality_of  :min_people_num, greater_than: 1, presence: true, only_integer: true, on: :update, if: :groups?
  validates_numericality_of  :coupon_price, greater_than: 0, presence: true, on: :update, if: :groups?
  validates_numericality_of  :item_price, greater_than: 0, presence: true, on: :update, if: :groups?
  validates_numericality_of  :get_limit_count, greater_than: 0, presence: true, only_integer: true, on: :update, if: :groups?
  validates_numericality_of  :get_limit_count, greater_than: 0, presence: true, only_integer: true, if: :vote?
  validates :question_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000, only_integer: true }, if: :fight?

  validates :partake_limit, :day_partake_limit, :prize_limit, :day_prize_limit, presence: true, numericality: { greater_than_or_equal_to: -1, only_integer: true }, if: :can_validate?

  belongs_to :activity
  belongs_to :activity_type

  def display_win_tip
    win_tip.presence || '请留下您的手机号码，我们的工作人员会联系发奖。'
  end

  enum_attr :activity_type_id, in: ActivityType::ENUM_ID_OPTIONS

  def no_prize_titles
    no_prize_title.to_s.split(/\s+/)
  end

  def self.win_pic_key
    'Fk1pS9IC1q5C2gVAkEhfvJN2nbTk'
  end

  def self.slot_pic_key
    'FmP_AWEx35d2zhFnIXx_55aaDMkS'
  end

end
