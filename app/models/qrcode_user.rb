class QrcodeUser < ActiveRecord::Base
	belongs_to :supplier
  belongs_to :wx_user
  belongs_to :qrcode

  scope :one_weeks, ->(today) { where("created_date >= ? and created_date <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("created_date >= ? and created_date <= ?", (today - 1.month), today) }
  scope :six_months, ->(today) { where("created_date >= ? and created_date <= ?", (today - 5.month), today) }
  scope :twelve_months, ->(today) { where("created_date >= ? and created_date <= ?", (today - 1.year), today) }
  scope :select_time, ->(start_time,end_time) { where("created_date >= ? and created_date <= ?", start_time, end_time) }

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', 2, '已删除'],
  ]

  before_save :save_total_amount_and_created_date

  private
	  def save_total_amount_and_created_date
	  	self.total_amount = vip_amount+ec_amount+restaurant_amount+take_out_amount+hotel_amount
	  	self.created_date = Date.today
	  end

end
