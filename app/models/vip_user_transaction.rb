class VipUserTransaction < ActiveRecord::Base
  DATES = {"one_weeks" => "最近7天", "one_months" => "最近一月", "six_months" => "最近半年", "twelve_months" => "最近一年"}
  belongs_to :site
  belongs_to :vip_user
  belongs_to :shop_branch
  belongs_to :transactionable, polymorphic: true

  store :meta, accessors: [:extra_remarks, :source]
  validates :amount, numericality: { greater_than: 0 }

  enum_attr :direction, in: [
    ['in',  1, '+'],
    ['out', 2, '-'],
  ]

  enum_attr :direction_type, in: [
    %w(up                增加     金额调节增加),
    %w(down              减少     金额调节减少),
    %w(pay_up            充值     充值),
    %w(pay_down          消费     消费),
    %w(ec_return         电商退还 电商退还余额),
    %w(recharge_given    充值赠送 充值赠送),
  ]

  enum_attr :amount_source, in: [
    ['shop_pay_up',    1, '后台充值'],
    ['shop_pay_down',  2, '后台消费'],
    ['web_pay_up',     3, '线上充值'],
    ['web_pay_down',   4, '线上消费'],
    ['ec_pay_down',    5, '电商消费'],
    ['hotel_pay_down', 6, '酒店消费'],
    ['recharge_discount', 7, '充值享折扣'],
    ['recharge_cash',  8, '充值送现金'],
  ]

  enum_attr :payment_type, in: [
    ['by_balance', 10005, '余额支付'],
    ['by_cash',    10000, '现金支付'],
    ['weixizhifu', 10001, '微信支付充值'],
    ['zhifubao',   10003, '支付宝充值'],
    # ['caifutong',  10004, '财付通充值']
  ]

  scope :by_pay, -> { where(direction_type: [PAY_UP,PAY_DOWN]) }
  scope :one_day, ->(day) { where("date(created_at) = ?", day) }
  scope :one_weeks, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 6.day), today) }
  scope :one_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.month), today) }
  scope :six_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 5.month), today) }
  scope :twelve_months, ->(today) { where("date(created_at) >= ? and date(created_at) <= ?", (today - 1.year), today) }
  scope :select_time, ->(start_time,end_time) { where("date(created_at) >= ? and date(created_at) <= ?", start_time, end_time) }
  scope :recent, -> { order('vip_user_transactions.id DESC') }

  after_create :send_recharge_consume_sms_notification

  def display_name
    amount_source_name.presence || direction_type_name
  end

  def transaction_amount
    new_amount = sprintf("%.2f", amount.round(2))
    "#{direction_name} #{new_amount}"
  end

  def created
    created_at.to_s[0..15]
  end

  def intro
    description.presence.try(:gsub, /_\w{8,15}/,"") #|| direction_type_name
  end

  def shop_branch_name
    shop_branch.try(:name) || '商户总部'
  end

  def exportings
    [ created_at.strftime('%F %T'), shop_branch_name, user_no, vip_user.try(:name), vip_user.try(:mobile), direction_type_name, amount, description].flatten
  end

  delegate :recharge_consume_sms_notify?, :user_no, to: :vip_user, allow_nil: true

  def need_send_vip_sms_notification?
    (pay_up? || pay_down?) && recharge_consume_sms_notify?
  end

  # TODO
  def send_recharge_consume_sms_notification
    if recharge_consume_sms_notify? && !by_cash?
      time = created_at.strftime '%-m月%-d日%R'
      options = { operation_id: 1, account_id: site.account_id, userable_id: user_id, userable_type: 'User' }
      message = "您卡号为#{vip_user.user_no}的会员卡于#{time}在#{vip_user.merchant_name}"
      message << ((pay_up? || pay_down?) ? direction_type_name : "进行金额调整操作，#{in? ? '上' : '下'}调")
      message << "#{sprintf('%.2f', amount.round(2))}元，交易后余额为#{sprintf('%.2f', usable_amount.round(2))}元。"
      # site.send_message(vip_user.mobile, message, false, options)
    end
  end

  def self.return_amount_to_vip_user!(vip_user, amount, params = {})
    VipUserTransaction.transaction do
      vip_user.change_amount_by!(amount)
      vip_user.vip_user_transactions.create! site_id:     vip_user.site_id,
                                             direction:      VipUserTransaction::IN,
                                             direction_type: VipUserTransaction::EC_RETURN,
                                             amount:         amount,
                                             total_amount:   vip_user.total_amount,
                                             usable_amount:  vip_user.usable_amount,
                                             description:    params[:description],
                                             source:         params[:source],
                                             order_no:       params[:out_trade_no]
    end
  end

  def self.create_recharge_given_transaction(vip_user, discount_amount: 0, given_amount: 0, shop_branch_id: nil)
    create_recharge_discount_transaction(vip_user, discount_amount, shop_branch_id)
    create_recharge_cash_transaction(vip_user, given_amount, shop_branch_id)
  end

  def self.create_recharge_discount_transaction(vip_user, amount, shop_branch_id)
    amount = amount.to_f
    return if amount <= 0

    transaction_attrs = recharge_given_attrs(vip_user, amount_source: RECHARGE_DISCOUNT, amount: amount, shop_branch_id: shop_branch_id)
    vip_user.vip_user_transactions.create(transaction_attrs)
  end

  def self.create_recharge_cash_transaction(vip_user, amount, shop_branch_id)
    amount = amount.to_f
    return if amount <= 0

    transaction_attrs = recharge_given_attrs(vip_user, amount_source: RECHARGE_CASH, amount: amount, shop_branch_id: shop_branch_id)
    vip_user.vip_user_transactions.create(transaction_attrs)
  end

  def self.recharge_given_attrs(vip_user, extra_attrs = {})
    {
      direction_type: RECHARGE_GIVEN,
      direction:      IN,
      total_amount:   vip_user.total_amount,
      usable_amount:  vip_user.usable_amount,
      site_id:    vip_user.site_id,
    }.merge(extra_attrs)
  end

  def self.export_excel(search,type)
    name, export_title = get_export_name_and_title(type)
    book_excel, book_sheet = new_excel(name)

    book_sheet.insert_row(0, export_title)
    search.each_with_index do |transaction, i|
      book_sheet.insert_row(i + 1, transaction.exportings)
    end
    StringIO.new.tap { |s| book_excel.write(s) }.string
  end

  def self.get_export_name_and_title(type)
    if type == 'point'
      ['积分记录', %w(时间 门店 会员卡号 会员姓名 手机号码 积分类型 积分 备注)]
    else
      ['消费记录', %w(时间 门店 会员卡号 会员姓名 手机号码 消费类型 金额 备注)]
    end
  end

  def self.new_excel(name)
    Spreadsheet.client_encoding = "UTF-8"
    book = Spreadsheet::Workbook.new
    bold_heading = Spreadsheet::Format.new(:weight => :bold, :align => :merge)
    # name = type == "point" ? "积分记录" : "消费记录"
    sheet = book.create_worksheet :name => name
    [book, sheet, bold_heading]
  end

  #==start数据魔方部分
  def self.cube_chart_data(total,date,today,select_time,params)
    data = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      hash = VipUserTransaction.cube_get_select_date(total,start_time,end_time)
    else
      hash, start_time, end_time = VipUserTransaction.cube_get_date(total,date,today)
    end
    hash.each do |key,value|
      categories << key
      data << value
    end
    min_tick = (end_time - start_time).to_i > 7 ? 7 : nil
    categories.map!{|time| Date.parse(time).strftime("%m/%d")} unless start_time == end_time
    [categories, data, start_time, end_time, min_tick]
  end

  def self.cube_get_select_date(total,start_time,end_time)
    diff_time = (end_time - start_time).to_i
    h = {}
    total_vip_users = total.select_time(start_time, end_time)
    if diff_time <= 1
      vip_users = total_vip_users.select('hour(created_at) as created_hour, sum(amount) as all_amount').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = VipUserTransaction.cube_get_hash_hour(h,vip_users)
    else
      vip_users = total_vip_users.select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = VipUserTransaction.cube_get_hash_day(h,vip_users)
    end
    return hash
  end

  def self.cube_get_date(total,date,today)
    h = {}
    vip_users = []
    hash = {}
    start_time = ""
    if date == "today"
      start_time = today
      end_time = today
      vip_users = total.one_day(start_time).select('hour(created_at) as created_hour, sum(amount) as all_amount').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = VipUserTransaction.cube_get_hash_hour(h,vip_users)
    elsif date == "yesterday"
      start_time = today.yesterday
      end_time = today.yesterday
      vip_users = total.one_day(start_time).select('hour(created_at) as created_hour, sum(amount) as all_amount').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = VipUserTransaction.cube_get_hash_hour(h,vip_users)
    elsif date == "one_weeks"
      vip_users = total.send(date, today).select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = VipUserTransaction.cube_get_hash_day(h,vip_users)
    elsif date == "one_months"
      vip_users = total.send(date, today).select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = VipUserTransaction.cube_get_hash_day(h,vip_users)
    end
    return hash,start_time,end_time
  end

  def self.cube_get_hash_hour(h,vip_users)
    vip_users.each do |value|
      h[value.created_hour] = value.all_amount.to_f
    end
    return h
  end

  def self.cube_get_hash_day(h,vip_users)
    vip_users.each do |value|
      h[value.created_date.try(:strftime, "%F")] = value.all_amount.to_f
    end
    return h
  end

  def self.cube_chart_base_line(categories, data, min_tick, type, time)
    if type == "pay_up"
      name = "充值金额"
      title = "#{time}会员充值金额"
    else
      name = "消费金额"
      title = "#{time}会员消费金额"
    end
     @chart = LazyHighCharts::HighChart.new('chart_basic_line') do |f|
      f.chart({ type: 'spline'})
      f.title({ text: title})
      f.credits({ enabled: false })
      f.xAxis({
          categories: categories,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: ""}
        })
      f.tooltip({
          crosshairs: true,
          shared: true
        })
      f.plotOptions({
          spline: {
            marker: {
              radius: 2,
              lineColor: '#666666',
              lineWidth: 1
            }
          }
        })
      f.series({
          name: name,
          marker: {
            symbol: 'circle'
          },
          data: data
        })

    end
  end

  def self.cube_export_excel(vip_users,type)
    xls_report = StringIO.new
    name = type == "pay_up" ? "充值金额" : "消费金额"
    book = VipUserTransaction.new_excel(name)
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['时间', name]
    sing_sheet = []
    sing_sheet << export_title

    vip_users.each_with_index do |vip_user,index|
      sing_sheet << [vip_user.created_date,vip_user.all_amount].flatten
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end
    book_excel.write(xls_report)
    return xls_report.string
  end
  #==end数据魔方部分
end
