class ChannelQrcode < ActiveRecord::Base

  DATES = {"one_weeks" => "最近7天", "one_months" => "最近一月", "six_months" => "最近半年", "twelve_months" => "最近一年"}

	belongs_to :site
	belongs_to :channel_type
  belongs_to :qrcode
	has_many :qrcode_logs, as: :qrcodeable

	attr_accessor :logo
	before_save :save_logo

	enum_attr :channel_way, :in => [
    ['online', 1, '线上'],
    ['offline', 2, '线下'],
    ['other', 3, '其他'],
  ]

	enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', 2, '已删除'],
  ]

  validates :channel_type_id, presence: true
  validates :name, presence: true, uniqueness: { scope: [:site_id, :status], message: '二维码名称不能重复', case_sensitive: false }, if: :normal?

  scope :latest, -> { order('created_at DESC') }

  def save_logo
    if logo != "unchange"
    	#require 'RMagick'
      wx_mp_user = site.wx_mp_user
    	wx_mp_user.auth!
    	attrs = {action_name: "QR_LIMIT_SCENE", action_info: {scene: {scene_id: scene_id}}}.to_json
      result = RestClient.post("https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{wx_mp_user.access_token}", attrs)
      info = JSON result
      # info = {'ticket' => "gQEQ8DoAAAAAAAAAASxodHRwOi8vd2VpeGluLnFxLmNvbS9xL0xFT1RjWlBtM2JTa3NFZjlnR19yAAIEBSUpUwMEAAAAAA=="}
      if info['ticket'].present?
        qrcode = wx_mp_user.qrcodes.where(ticket: info['ticket']).first
        qrcode ||= wx_mp_user.qrcodes.create(site_id: site_id, name: name, expire_seconds: info['expire_seconds'].presence, action_name: "QR_LIMIT_SCENE", scene_id: scene_id, ticket: info['ticket'], description: description)
        url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{info['ticket']}"
        self.qrcode_id = qrcode.id
        img = Magick::ImageList.new
        qrcode = open(url)
        qrcode_img = img.from_blob(qrcode.read).resize(1280, 1280)

        if logo.present?
          img_url = qiniu_image_url(logo)
          logo_img = Magick::Image.from_blob(open(img_url).read).first
          qrcode_img = qrcode_img.composite(logo_img.resize(260, 260), 510, 510, Magick::OverCompositeOp)#.to_blob
        end
        self.pic_key = ImgUploadQiniu.upload_qiniu(qrcode_img.to_blob)
      end
      # system("rm -rf #{Rails.root.to_s}/public/qrcode_logo/*")
    end
  end

  def download(type)
    img = Magick::ImageList.new
    qrcode = open(qiniu_image_url(pic_key))
    return case type
    when "258" then img.from_blob(qrcode.read).resize(258, 258).to_blob
    when "344" then img.from_blob(qrcode.read).resize(344, 344).to_blob
    when "430" then img.from_blob(qrcode.read).resize(430, 430).to_blob
    when "860" then img.from_blob(qrcode.read).resize(860, 860).to_blob
    when "1280" then img.from_blob(qrcode.read).resize(1280, 1280).to_blob
    else img.from_blob(qrcode.read).resize(258, 258).to_blob
    end
  rescue => e
    ""
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def self.chart_data(total,date,today,select_time,params,total_qrcode_logs,channel_qrcodes)
    count = 0
    series = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      # total.each do |channel_qrcode|
      channel_qrcodes.each do |channel_qrcode|
        hash = {'name' => channel_qrcode.name}
        # categories,hash['data'],count = ChannelQrcode.get_select_date(total_qrcode_logs,channel_qrcode,start_time,end_time,count)
        categories,hash['data'] = ChannelQrcode.get_select_date(total_qrcode_logs,channel_qrcode,start_time,end_time)
        series << hash
      end
    else
      # total.each do |channel_qrcode|
      channel_qrcodes.each do |channel_qrcode|
        hash = {'name' => channel_qrcode.name}
        # categories,hash['data'],count,start_time,end_time = ChannelQrcode.get_date(total_qrcode_logs,channel_qrcode,date,today,count)
        categories,hash['data'],start_time,end_time = ChannelQrcode.get_date(total_qrcode_logs,channel_qrcode,date,today)
        series << hash
      end
    end
    count = total_qrcode_logs.channel_qrcode_normal(total.pluck(:id)).select_time(start_time, end_time).select(:id).count
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, count, min_tick]
  end

  # def self.get_date_count(total_qrcode_logs,channel_qrcode,date,today,count)
  #   total = total_qrcode_logs.channel_qrcode_normal(channel_qrcode.id).send(date, today)
  #   count += total.length
  #   count
  # end

  # def self.get_select_date_count(total_qrcode_logs,channel_qrcode,start_time,end_time,count)
  #   total = total_qrcode_logs.channel_qrcode_normal(channel_qrcode.id).select_time(start_time, end_time)
  #   count += total.length
  #   count
  # end

  def self.get_select_date(total_qrcode_logs,channel_qrcode,start_time,end_time)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = total_qrcode_logs.channel_qrcode_normal(channel_qrcode.id).select_time(start_time, end_time)
    # count += total.length
    if diff_time <= 31
      qrcode_logs = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day(h,qrcode_logs)
    elsif diff_time > 31 &&  diff_time < 365
      qrcode_logs = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month(h,qrcode_logs)
    elsif diff_time > 365
      qrcode_logs = total.select('year(created_at) as created_year, count(*) as count').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories,data = ChannelQrcode.get_hash_year(h,qrcode_logs)
    end
    # return categories,data,count
    return categories,data
  end

  def self.get_date(total_qrcode_logs,channel_qrcode,date,today)
    h = {}
    total = total_qrcode_logs.channel_qrcode_normal(channel_qrcode.id).send(date, today)
    # count += total.length
    if date == "one_weeks"
      qrcode_logs = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day(h,qrcode_logs)
    elsif date == "one_months"
      qrcode_logs = total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day(h,qrcode_logs)
    elsif date == "six_months"
      qrcode_logs = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 5.month
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month(h,qrcode_logs)
    elsif date == "twelve_months"
      qrcode_logs = total.select('year(created_at) as created_year, month(created_at) as created_month, count(*) as count').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 1.year
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month(h,qrcode_logs)
    end
    # return categories,data,count,start_time,today
    return categories,data,start_time,today
  end

  def self.get_hash_day(h,qrcode_logs)
    qrcode_logs.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.count
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.get_hash_month(h,qrcode_logs)
    qrcode_logs.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.get_hash_year(h,qrcode_logs)
    qrcode_logs.each do |value|
      key = value.created_year.to_s
      h[key] = value.count
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.chart_base_line(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line1') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "用户关注趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "用户关注趋势图"},
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
          layout: 'horizontal',
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

  def self.chart_data_amount(total,date,today,select_time,params,channel_qrcodes)
    amount = 0
    series = []
    categories = []
    if select_time
      start_time = Date.parse(params[:start_time])
      end_time = Date.parse(params[:end_time])
      # total.each do |channel_qrcode|
      channel_qrcodes.each do |channel_qrcode|
        hash = {'name' => channel_qrcode.name}
        # categories,hash['data'],amount = ChannelQrcode.get_select_date_amount(channel_qrcode,start_time,end_time,amount)
        categories,hash['data'] = ChannelQrcode.get_select_date_amount(channel_qrcode,start_time,end_time)
        series << hash
      end
      amount = QrcodeUser.where(qrcode_id: total.pluck(:qrcode_id)).select(:total_amount).sum(:total_amount)
    else
      # total.each do |channel_qrcode|
      channel_qrcodes.each do |channel_qrcode|
        hash = {'name' => channel_qrcode.name}
        categories,hash['data'],start_time,end_time = ChannelQrcode.get_date_amount(channel_qrcode,date,today)
        series << hash
      end
      # total.each do |channel_qrcode|
      #   total_qrcode_users = channel_qrcode.qrcode.qrcode_users.send(date, today) rescue QrcodeUser.none
      #   amount += total_qrcode_users.sum(:total_amount)
      # end
      amount = QrcodeUser.where(qrcode_id: total.pluck(:qrcode_id)).send(date, today).select(:total_amount).sum(:total_amount)
    end
    min_tick = categories.length > 7 ? 6 : nil
    [categories, series, start_time, end_time, amount, min_tick]
  end

  # def self.get_select_date_amount(channel_qrcode,start_time,end_time,amount)
  def self.get_select_date_amount(channel_qrcode,start_time,end_time)
    diff_time = (start_time - end_time).to_i
    h = {}
    total = channel_qrcode.qrcode.qrcode_users.select_time(start_time, end_time)
    # amount += total.sum(:total_amount)
    if diff_time <= 31
      qrcode_users = total.select('created_date, sum(total_amount) as amount').group('created_date').order("created_at asc")
      (start_time..end_time).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day_amount(h,qrcode_users)
    elsif diff_time > 31 &&  diff_time < 365
      qrcode_users = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(total_amount) as amount').group('year(created_at),month(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month_amount(h,qrcode_users)
    elsif diff_time > 365
      qrcode_users = total.select('year(created_at) as created_year, sum(total_amount) as amount').group('year(created_at)').order("created_at asc")
      (start_time..end_time).collect{|item| item.year.to_s}.uniq.each do |year|
        h[year] = 0
      end
      categories,data = ChannelQrcode.get_hash_year_amount(h,qrcode_users)
    end
    # return categories,data,amount
    return categories,data
  end

  # def self.get_date_amount(channel_qrcode,date,today,amount)
  def self.get_date_amount(channel_qrcode,date,today)
    h = {}
    total = channel_qrcode.qrcode.qrcode_users.send(date, today) rescue QrcodeUser.none
    # amount += total.sum(:total_amount)
    if date == "one_weeks"
      qrcode_users = total.select('created_date, sum(total_amount) as amount').group('created_date').order("created_at asc")
      start_time = today - 6.day
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day_amount(h,qrcode_users)
    elsif date == "one_months"
      qrcode_users = total.select('created_date, sum(total_amount) as amount').group('created_date').order("created_at asc")
      start_time = today - 1.month
      (start_time..today).each do |day|
        h[day.try(:strftime, "%m-%d")] = 0
      end
      categories,data = ChannelQrcode.get_hash_day_amount(h,qrcode_users)
    elsif date == "six_months"
      qrcode_users = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(total_amount) as amount').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 5.month
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month_amount(h,qrcode_users)
    elsif date == "twelve_months"
      qrcode_users = total.select('year(created_at) as created_year, month(created_at) as created_month, sum(total_amount) as amount').group('year(created_at),month(created_at)').order("created_at asc")
      start_time = today - 1.year
      (start_time..today).collect{|item| item.year.to_s+"-"+item.month.to_s}.uniq.each do |month|
        h[month] = 0
      end
      categories,data = ChannelQrcode.get_hash_month_amount(h,qrcode_users)
    end
    # return categories,data,amount,start_time,today
    return categories,data,start_time,today
  end

  def self.get_hash_day_amount(h,qrcode_users)
    qrcode_users.each do |value|
      h[value.created_date.try(:strftime, "%m-%d")] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.get_hash_month_amount(h,qrcode_users)
    qrcode_users.each do |value|
      key = value.created_year.to_s + "-" + value.created_month.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.get_hash_year_amount(h,qrcode_users)
    qrcode_users.each do |value|
      key = value.created_year.to_s
      h[key] = value.amount.to_f
    end
    categories = h.keys
    data = h.values
    return categories,data
  end

  def self.chart_base_line_amount(categories, series, min_tick)
    @chart = LazyHighCharts::HighChart.new('chart_basic_line2') do |f|
      f.chart({ type: 'line',
          marginRight: 10,
          # marginBottom: 25,
          height: 305
          })
      f.title({ text: "销售额趋势图"})
      f.xAxis({
          categories: categories,
          # max:20,
          minTickInterval: min_tick
        })
      f.yAxis({
          title:{text: "销售额趋势图"},
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
          width: 500,
          borderWidth: 0
        })
      series.each do |serie|
        f.series({
          name: serie['name'],
          data: serie['data']
        })
      end
    end
  end

end
