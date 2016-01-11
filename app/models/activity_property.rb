# == Schema Information
#
# Table name: activity_properties
#
#  id                :integer          not null, primary key
#  activity_id       :integer          not null
#  activity_type_id  :integer          not null
#  prize_pic         :string(255)
#  partake_limit     :integer          default(-1), not null
#  day_partake_limit :integer          default(-1), not null
#  prize_limit       :integer          default(-1), not null
#  day_prize_limit   :integer          default(-1), not null
#  is_show_prize_qty :boolean          default(TRUE)
#  item_name         :string(255)
#  special_warn      :text
#  min_people_num    :integer          default(0), not null
#  coupon_price      :decimal(12, 2)   default(0.0), not null
#  item_price        :decimal(12, 2)   default(0.0), not null
#  coupon_count      :integer          default(0), not null
#  get_limit_count   :integer          default(0), not null
#  repeat_draw_msg   :string(255)      default("亲，抢券活动每人只能抽一次哦。")
#  question_score    :integer          default(10)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ActivityProperty < ActiveRecord::Base

  include Concerns::ActsAsCoupon

  store :meta, accessors: [ :no_prize_title, :consume_day_allow_count ], coder: JSON

  validates :item_name, length: { maximum: 10 }, presence: true, on: :update, if: :groups?
  validates :special_warn, length: { maximum: 2000 }, presence: true, if: :fight?
  validates_numericality_of  :min_people_num, greater_than: 1, presence: true, only_integer: true, on: :update, if: :groups?
  validates_numericality_of  :coupon_price, greater_than: 0, presence: true, on: :update, if: :groups?
  validates_numericality_of  :item_price, greater_than: 0, presence: true, on: :update, if: :groups?
  validates_numericality_of  :get_limit_count, greater_than: 0, presence: true, only_integer: true, on: :update, if: :groups?
  validates_numericality_of  :get_limit_count, greater_than: 0, presence: true, only_integer: true, if: :vote?
  validates_numericality_of  :coupon_count, :get_limit_count, greater_than: 0, presence: true, on: :update, if: :consume?
  validates  :repeat_draw_msg, presence: true, on: :update, if: :consume?
  validates :question_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000, only_integer: true }, if: :fight?
  validates :coupon_count, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: :old_coupon?

  validates :partake_limit, :day_partake_limit, :prize_limit, :day_prize_limit, presence: true, numericality: { greater_than_or_equal_to: -1, only_integer: true }, if: :can_validate?

  belongs_to :activity
  belongs_to :activity_type

  def display_win_tip
    win_tip.presence || '请留下您的手机号码，我们的工作人员会联系发奖。'
  end

  enum_attr :activity_type_id, in: ActivityType::ENUM_ID_OPTIONS

  def old_coupon?
    activity_type_id == 3
  end

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
