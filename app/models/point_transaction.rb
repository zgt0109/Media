# == Schema Information
#
# Table name: point_transactions
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  vip_user_id    :integer          not null
#  point_type_id  :integer          not null
#  direction_type :integer          default(1), not null
#  points         :integer          not null
#  pointable_id   :integer
#  pointable_type :string(255)
#  status         :integer          default(1), not null
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PointTransaction < ActiveRecord::Base
  belongs_to :site
  belongs_to :vip_user, inverse_of: :vip_user_transactions
  belongs_to :shop_branch
  belongs_to :point_type
  belongs_to :pointable, polymorphic: true

  enum_attr :direction_type, in: [
    ['in',             1,  '签到赚取'],
    ['out',            2,  '消费'],
    ['recharge_in',    3,  '充值赚取'],
    ['consume_in',     4,  '消费赚取'],
    ['adjust_in',      5,  '积分调节赚取'],
    ['ec_purchase',    6,  '电商消费'],
    ['ec_return',      7,  '电商退还'],
    ['hotel_purchase', 8,  '酒店消费'],
    ['hotel_return',   9,  '酒店退还'],
    ['activity_out',   10, '活动消费'],
    ['activity_prize', 11, '活动积分奖励'],
    ['register_card_in', 13, '领卡赚取'],
    ['spm_in', 14, '商品码奖励'],
  ]

  scope :latest, -> { order('created_at DESC') }
  scope :by_direction_type, -> (type = nil) {
    if type.to_s =~ /^in|out|recharge_in|consume_in|adjust_in|ec_purchase|ec_return|hotel_purchase|hotel_return$/
      value = PointTransaction.const_get(type.upcase)
      value = [value, EC_PURCHASE, HOTEL_PURCHASE] if value == OUT
      where(direction_type: value)
    end
  }
  scope :by_money, -> (type = nil) { where(direction_type: [RECHARGE_IN,CONSUME_IN,ADJUST_IN]) if type == "money" }
  scope :select_date, ->(created_at) { where("created_at = ?", created_at) unless created_at.nil?}

  scope :one_day, ->(day) { where("date(created_at) = ?", day) }
  scope :one_hour, ->(hour) { where("hour(created_at) = ?", hour) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :six_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 5.month), today) }
  scope :twelve_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.year), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :in_point, -> { where(direction_type: [IN,RECHARGE_IN,CONSUME_IN,ADJUST_IN,REGISTER_CARD_IN]) }

  def self.used_points
    where(direction_type: [OUT, EC_PURCHASE]).sum(:points)
  end

  def pointable_name
  	case pointable_type
  	when "PointGift" then "兑换礼品：#{pointable.try(:name)}"
  	else
  		point_type.try(:category_name) || '积分奖励'
  	end
  end

  def transaction_amount
    "#{direction_name} #{points}"
  end

  def direction_name
    out? || ec_purchase? || hotel_purchase? ? '-' : '+'
  end

  def created
    created_at.to_s[0..15]
  end

  def intro
    description.presence #|| "积分调节"
  end

  def shop_branch_name
    shop_branch.try(:name) || '商户总部'
  end

  def exportings
    [created_at.strftime('%F %T'), shop_branch_name, vip_user.try(:user_no), vip_user.try(:name), vip_user.try(:mobile), direction_type_name, points, description].flatten
  end

  #==start数据魔方部分
  def self.cube_export_excel(total)
    book = PointTransaction.new_excel
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['时间', "新增积分", "消费积分", "累计积分"]
    sing_sheet = []
    sing_sheet << export_title

    total.group('date(created_at)').order("created_at desc").each_with_index do |point,index|
      up_points = total.one_day(point.created_at.to_date).in_point.sum(:points)
      down_points = total.one_day(point.created_at.to_date).out.sum(:points)
      all_points = up_points - down_points
      sing_sheet << [point.created_at.to_date,up_points,down_points,all_points].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end

    StringIO.new.tap { |s| book_excel.write(s) }.string
  end

  def self.new_excel(title: '会员积分')
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(weight: :bold, align: :merge)
    sheet = book.create_worksheet name: title
    return [book,sheet,bold_heading]
  end
  #==end数据魔方部分

end
