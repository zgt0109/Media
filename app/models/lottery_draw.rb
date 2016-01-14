class LotteryDraw < ActiveRecord::Base

  belongs_to :site
  belongs_to :user
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
