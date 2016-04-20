module Biz::HighchartHelper

  def get_hash_day(h,transactions)
    transactions.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.count
    end
    return h
  end

  def get_hash_month(h,transactions)
    transactions.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.count
    end
    return h
  end

  #门店，分店统计
  def chart_transaction_data_for_shop_branch(shop_branch,date,today)
    transactions = shop_branch.vip_user_transactions.by_pay.send(date, today)
    hash_pay_up,start_time_pay_up,count_pay_up = get_date_for_shop_branch(date,today,transactions.pay_up,"count(*)")
    categories_pay_up = []
    data_pay_up = []
    hash_pay_up.each do |key,value|
      categories_pay_up << key
      data_pay_up << value
    end

    hash_pay_down,start_time_pay_down,count_pay_down = get_date_for_shop_branch(date,today,transactions.pay_down,"count(*)")
    data_pay_down = []
    hash_pay_down.each do |key,value|
      data_pay_down << value
    end

    hash_pay_up_money,start_time_pay_up_money,count_pay_up_money = get_date_for_shop_branch(date,today,transactions.pay_up,"sum(amount)")
    data_pay_up_money = []
    hash_pay_up_money.each do |key,value|
      data_pay_up_money << value.to_f
    end

    hash_pay_down_money,start_time_pay_down_money,count_pay_down_money = get_date_for_shop_branch(date,today,transactions.pay_down,"sum(amount)")
    data_pay_down_money = []
    hash_pay_down_money.each do |key,value|
      data_pay_down_money << value.to_f
    end

    [categories_pay_up, data_pay_up, data_pay_down, data_pay_up_money, data_pay_down_money, start_time_pay_up, count_pay_up, count_pay_down, count_pay_up_money, count_pay_down_money]
  end

  def get_date_for_shop_branch(date,today,total,sql)
    h = {}
    transactions = []
    hash = {}
    start_time = ""
    if date == "one_weeks"
      transactions = total.select("date(created_at) as created_date, #{sql} as count").group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,transactions)
    elsif date == "one_months"
      transactions = total.select("date(created_at) as created_date, #{sql} as count").group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,transactions)
    elsif date == "six_months"
      transactions = total.select("year(created_at) as created_year, month(created_at) as created_month, #{sql} as count").group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 5.month
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,transactions)
    elsif date == "twelve_months"
      transactions = total.select("year(created_at) as created_year, month(created_at) as created_month, #{sql} as count").group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 1.year
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,transactions)
    end
    return hash,start_time,(sql.include?("sum") ? total.sum(:amount) : total.count)
  end

  def chart_transaction_base_line_for_shop_branch(categories, data_pay_up, data_pay_down, data_pay_up_money, data_pay_down_money, date, status=false)
    min_tick = categories.length > 7 ? 6 : nil
    width = status ? 770 : ""
     @chart = LazyHighCharts::HighChart.new('chart_basic_line1') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          marginBottom: 25,
          height: 305,
          width: 770
          })
      f.title({ text: "#{date}消费次数、充值次数趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "#{date}消费次数、充值次数趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "次"
        })
      f.legend({
          layout: 'horizontal',
          align: 'right',
          verticalAlign: 'top',
          borderWidth: 0
        })
      f.series({
          name: "充值次数",
          data: data_pay_up
        })
      f.series({
          name: "消费次数",
          data: data_pay_down
        })
    end
    @chart_money = LazyHighCharts::HighChart.new('chart_basic_line2') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          marginBottom: 25,
          height: 305,
          width: 770
          })
      f.title({ text: "#{date}消费金额、充值金额趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "#{date}消费金额、充值金额趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "元"
        })
      f.legend({
          layout: 'horizontal',
          align: 'right',
          verticalAlign: 'top',
          borderWidth: 0
        })
      f.series({
          name: "充值金额",
          data: data_pay_up_money
        })
      f.series({
          name: "消费金额",
          data: data_pay_down_money
        })
    end
    [@chart, @chart_money]
  end

  #消费记录
  def chart_transaction_data_for_vip_record(current_site,date,today)
    total_money = current_site.vip_user_transactions.by_pay.send(date, today)
    hash_money,start_time_money,count_money = get_date_for_vip_record(current_site,date,today,total_money)
    categories_money = []
    data_money = []
    hash_money.each do |key,value|
      categories_money << key
      data_money << value
    end

    total_point = current_site.point_transactions.send(date, today)
    hash_point,start_time_point,count_point = get_date_for_vip_record(current_site,date,today,total_point)
    data_point = []
    hash_point.each do |key,value|
      data_point << value
    end

    [categories_money, data_money, data_point, start_time_money, count_money]
  end

  def get_date_for_vip_record(current_site,date,today,total)
    h = {}
    transactions = []
    hash = {}
    start_time = ""
    # total = current_site.vip_users.normal_and_freeze.send(date, today)
    if date == "one_weeks"
      transactions = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,transactions)
    elsif date == "one_months"
      transactions = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,transactions)
    elsif date == "six_months"
      transactions = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 5.month
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,transactions)
    elsif date == "twelve_months"
      transactions = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 1.year
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,transactions)
    end
    return hash,start_time,total.count
  end

  def chart_transaction_base_line_for_vip_record(categories, data_money, data_point, date)
    min_tick = categories.length > 7 ? 6 : nil
     @chart = LazyHighCharts::HighChart.new('chart_basic_line') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          marginBottom: 25,
          height: 305
          })
      f.title({ text: "#{date}消费次数趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "#{date}消费次数趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "次"
        })
      f.legend({
          layout: 'horizontal',
          align: 'right',
          verticalAlign: 'top',
          borderWidth: 0
        })
      f.series({
          name: "消费金额",
          data: data_money
        })
      f.series({
          name: "消费积分",
          data: data_point
        })

    end
  end

  #会员卡统计
  def chart_data_for_vip_card(current_site,date,today)
    hash,start_time,count = get_date_for_vip_card(current_site,date,today)
    categories = []
    data = []
    hash.each do |key,value|
      categories << key
      data << value
    end
    [categories, data, start_time, count]
  end

  def get_date_for_vip_card(current_site,date,today)
    h = {}
    vip_users = []
    hash = {}
    start_time = ""
    total = current_site.vip_users.normal_and_freeze.send(date, today)
    if date == "one_weeks"
      vip_users = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,vip_users)
    elsif date == "one_months"
      vip_users = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      hash = get_hash_day(h,vip_users)
    elsif date == "six_months"
      vip_users = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 5.month
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,vip_users)
    elsif date == "twelve_months"
      vip_users = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 1.year
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      hash = get_hash_month(h,vip_users)
    end
    return hash,start_time,total.count
  end

  def chart_base_line_for_vip_card(categories, data, date)
    min_tick = categories.length > 7 ? 6 : nil
     @chart = LazyHighCharts::HighChart.new('chart_basic_line') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          marginBottom: 25,
          height: 305
          })
      f.title({ text: "#{date}新增会员趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "#{date}新增会员趋势图"},
          plotLines: [{
              value: 0,
              width: 1,
              color: '#808080'
            }]
        })
      f.tooltip({
          valueSuffix: "人"
        })
      f.legend({
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'top',
          x: -5,
          y: 100,
          borderWidth: 0
        })
      f.series({
          showInLegend: false,
          name: "新增",
          data: data
        })

    end
  end

  #==start数据魔方部分
  #会员充值，会员消费
  def cube_chart_data_for_datacube_amount(total,date,today,select_time,params)
    data = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      hash = cube_get_select_date_for_datacube_amount(total,start_time,end_time)
    else
      hash, start_time, end_time = cube_get_date_for_datacube_amount(total,date,today)
    end
    hash.each do |key,value|
      categories << key
      data << value
    end
    min_tick = (end_time - start_time).to_i > 7 ? 7 : nil
    categories.map!{|time| Date.parse(time).strftime("%m/%d")} unless start_time == end_time
    [categories, data, start_time, end_time, min_tick]
  end

  def cube_get_select_date_for_datacube_amount(total,start_time,end_time)
    diff_time = (end_time - start_time).to_i
    h = {}
    total_vip_users = total.select_time(start_time, end_time)
    if diff_time <= 1
      vip_users = total_vip_users.select('hour(created_at) as created_hour, sum(amount) as all_amount').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = cube_get_hash_hour_for_datacube_amount(h,vip_users)
    else
      vip_users = total_vip_users.select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_amount(h,vip_users)
    end
    return hash
  end

  def cube_get_date_for_datacube_amount(total,date,today)
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
      hash = cube_get_hash_hour_for_datacube_amount(h,vip_users)
    elsif date == "yesterday"
      start_time = today.yesterday
      end_time = today.yesterday
      vip_users = total.one_day(start_time).select('hour(created_at) as created_hour, sum(amount) as all_amount').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = cube_get_hash_hour_for_datacube_amount(h,vip_users)
    elsif date == "one_weeks"
      vip_users = total.send(date, today).select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_amount(h,vip_users)
    elsif date == "one_months"
      vip_users = total.send(date, today).select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_amount(h,vip_users)
    end
    return hash,start_time,end_time
  end

  def cube_get_hash_hour_for_datacube_amount(h,vip_users)
    vip_users.each do |value|
      h[value.created_hour] = value.all_amount.to_f
    end
    return h
  end

  def cube_get_hash_day_for_datacube_amount(h,vip_users)
    vip_users.each do |value|
      h[value.created_date.try(:strftime, "%F")] = value.all_amount.to_f
    end
    return h
  end

  def cube_chart_base_line_for_datacube_amount(categories, data, min_tick, type, time)
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

  #会员数
  def cube_chart_data_for_datacube_vip_card(total, date, today, select_time = false, params = {})
    data = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      hash = cube_get_select_date_for_datacube_vip_card(total,start_time,end_time)
    else
      hash, start_time, end_time = cube_get_date_for_datacube_vip_card(total,date,today)
    end
    hash.each do |key,value|
      categories << key
      data << value
    end
    min_tick = (end_time - start_time).to_i > 7 ? 7 : nil
    categories.map!{|time| Date.parse(time).strftime("%m/%d")} if start_time != end_time && (end_time - start_time).to_i != 1
    [categories, data, start_time, end_time, min_tick]
  end

  def cube_get_select_date_for_datacube_vip_card(total,start_time,end_time)
    diff_time = (end_time - start_time).to_i
    h = {}
    total_vip_users = total.select_time(start_time, end_time)
    if diff_time <= 1
      vip_users = total_vip_users.select('hour(created_at) as created_hour, count(*) as count').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = cube_get_hash_hour_for_datacube_vip_card(h,vip_users)
    else
      vip_users = total_vip_users.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_vip_card(h,vip_users)
    end
    return hash
  end

  def cube_get_date_for_datacube_vip_card(total,date,today)
    h = {}
    vip_users = []
    hash = {}
    start_time = ""
    if date == "today"
      start_time = today
      end_time = today
      vip_users = total.one_day(start_time).select('hour(created_at) as created_hour, count(*) as count').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = cube_get_hash_hour_for_datacube_vip_card(h,vip_users)
    elsif date == "yesterday"
      start_time = today.yesterday
      end_time = today.yesterday
      vip_users = total.one_day(start_time).select('hour(created_at) as created_hour, count(*) as count').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = 0
      end
      hash = cube_get_hash_hour_for_datacube_vip_card(h,vip_users)
    elsif date == "one_weeks"
      vip_users = total.send(date, today).select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_vip_card(h,vip_users)
    elsif date == "one_months"
      vip_users = total.send(date, today).select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = 0
      end
      hash = cube_get_hash_day_for_datacube_vip_card(h,vip_users)
    end
    return hash,start_time,end_time
  end

  def cube_get_hash_hour_for_datacube_vip_card(h,vip_users)
    vip_users.each do |value|
      h[value.created_hour] = value.count
    end
    return h
  end

  def cube_get_hash_day_for_datacube_vip_card(h,vip_users)
    vip_users.each do |value|
      h[value.created_date.try(:strftime, "%F")] = value.count
    end
    return h
  end

  def cube_chart_base_line_for_datacube_vip_card(categories, data, min_tick, title = '')
     @chart = LazyHighCharts::HighChart.new('chart_basic_line') do |f|
      f.chart({ type: 'spline'})
      f.title({ text: title})
      f.credits({ enabled: false })
      f.xAxis({
          categories: categories,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: ''}
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
          name: "新增",
          marker: {
            symbol: 'circle'
          },
          data: data
        })

    end
  end

  #会员积分
  def cube_chart_data_for_datacube_point(total,date,today,select_time,params)
    data_up = []
    data_down = []
    data_all = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      hash = cube_get_select_date_for_datacube_point(total,start_time,end_time)
    else
      hash, start_time, end_time = cube_get_date_for_datacube_point(total,date,today)
    end
    hash.each do |key,value|
      categories << key
      data_up << value[0]
      data_down << value[1]
      data_all << value[2]
    end
    min_tick = (end_time - start_time).to_i > 7 ? 7 : nil
    categories.map!{|time| Date.parse(time).strftime("%m/%d")} unless start_time == end_time
    [categories, data_up, data_down, data_all, start_time, end_time, min_tick]
  end

  def cube_get_select_date_for_datacube_point(total,start_time,end_time)
    diff_time = (end_time - start_time).to_i
    h = {}
    total_point_transactions = total.select_time(start_time, end_time)
    if diff_time <= 1
      point_transactions = total_point_transactions.select('hour(created_at) as created_hour').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = [0,0,0]
      end
      hash = cube_get_hash_hour_for_datacube_point(h,point_transactions,total_point_transactions)
    else
      point_transactions = total_point_transactions.select('date(created_at) as created_date').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = [0,0,0]
      end
      hash = cube_get_hash_day_for_datacube_point(h,point_transactions,total_point_transactions)
    end
    return hash
  end

  def cube_get_date_for_datacube_point(total,date,today)
    h = {}
    point_transactions = []
    hash = {}
    start_time = ""
    if date == "today"
      start_time = today
      end_time = today
      total_point_transactions = total.one_day(start_time)
      point_transactions = total_point_transactions.select('hour(created_at) as created_hour').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = [0,0,0]
      end
      hash = cube_get_hash_hour_for_datacube_point(h,point_transactions,total_point_transactions)
    elsif date == "yesterday"
      start_time = today.yesterday
      end_time = today.yesterday
      total_point_transactions = total.one_day(start_time)
      point_transactions = total_point_transactions.select('hour(created_at) as created_hour').group('hour(created_at)').order("created_at asc")
      (0..23).each do |hour|
        h[hour] = [0,0,0]
      end
      hash = cube_get_hash_hour_for_datacube_point(h,point_transactions,total_point_transactions)
    elsif date == "one_weeks"
      total_point_transactions = total.send(date, today)
      point_transactions = total_point_transactions.select('date(created_at) as created_date').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = [0,0,0]
      end
      hash = cube_get_hash_day_for_datacube_point(h,point_transactions,total_point_transactions)
    elsif date == "one_months"
      total_point_transactions = total.send(date, today)
      point_transactions = total_point_transactions.select('date(created_at) as created_date').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      end_time = today
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%F")] = [0,0,0]
      end
      hash = cube_get_hash_day_for_datacube_point(h,point_transactions,total_point_transactions)
    end
    return hash,start_time,end_time
  end

  def cube_get_hash_hour_for_datacube_point(h,point_transactions,total_point_transactions)
    point_transactions.each do |value|
      up_points = total_point_transactions.in_point.one_hour(value.created_hour).sum(:points)
      down_points = total_point_transactions.out.one_hour(value.created_hour).sum(:points)
      all_points = up_points - down_points
      h[value.created_hour] = [up_points,down_points,all_points]
    end
    return h
  end

  def cube_get_hash_day_for_datacube_point(h,point_transactions,total_point_transactions)
    point_transactions.each do |value|
      up_points = total_point_transactions.in_point.one_day(value.created_date).sum(:points)
      down_points = total_point_transactions.out.one_day(value.created_date).sum(:points)
      all_points = up_points - down_points
      h[value.created_date.try(:strftime, "%F")] = [up_points,down_points,all_points]
    end
    return h
  end

  def cube_chart_base_line_for_datacube_point(categories, data_up, data_down, data_all, min_tick, title)
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
      f.legend({
          layout: 'horizontal',
          align: 'center',
          width: 235
        })
      f.series({
          name: "新增积分",
          marker: {
            symbol: 'circle'
          },
          data: data_up
        })
      f.series({
          name: "消费积分",
          marker: {
            symbol: 'circle'
          },
          data: data_down
        })
      f.series({
          name: "累积积分",
          marker: {
            symbol: 'circle'
          },
          data: data_all
        })

    end
  end
  #==end数据魔方部分
end