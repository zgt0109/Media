# == Schema Information
#
# Table name: lottery_draws
#
#  id                :integer          not null, primary key
#  supplier_id       :integer          not null
#  wx_mp_user_id     :integer          not null
#  wx_user_id        :integer          not null
#  activity_id       :integer          not null
#  activity_prize_id :integer
#  status            :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class LotteryDraw < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :wx_user
  belongs_to :activity
  belongs_to :activity_prize

  enum_attr :status, :in => [
    ['unwin', 0, '未中奖'],
    ['win', 1, '中奖']
  ]

  scope :today, -> { where(created_at: Date.today.beginning_of_day..Date.today.end_of_day) }
  # before_save -> { self.attributes['created_date'] = Date.today; puts self.attributes }
  before_save -> { self.created_date = Date.today if LotteryDraw.column_names.include?('created_date') }
end
