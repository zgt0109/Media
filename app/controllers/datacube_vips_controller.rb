class DatacubeVipsController < ApplicationController
  include Biz::HighchartHelper

  before_filter do
    @partialLeftNav = "/layouts/partialLeftDC"
  end

  def index
    @total = current_user.vip_users.normal_and_freeze
    @select_vip_users = @total.select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at desc")
    # vip_users = @select_vip_users.page(params[:page])

    if params[:select_time].present?
      select_time = true 
      params[:start_time] = params[:select_time].split(' - ')[0]
      params[:end_time] = params[:select_time].split(' - ')[1]
    end
    @date = params[:created_date].present? ? params[:created_date] : "today"
    @today = Date.today
    @categories, @data, @start_time, @end_time, min_tick = cube_chart_data_for_datacube_vip_card(@total,@date,@today,select_time,params)

    @total_counts = @total.count
    @today_counts = @total.where("date(created_at) = ?",@today).count
    @yesterday_counts = @total.where("date(created_at) = ?",@today-1.day).count
    @week_counts = @total.one_weeks(@today).count
    @month_counts = @total.one_months(@today).count
    @datetime = @start_time.to_s + " - " + @end_time.to_s

    @chart = cube_chart_base_line_for_datacube_vip_card(@categories, @data, min_tick, "#{@datetime}新增会员数") if @categories.present?

    t = @select_vip_users.to_a
    @t = [*@start_time..@end_time].map do |date|
      t.find { |u2| u2.created_date == date } || OpenStruct.new(created_date: date, count: 0)
    end.reverse

    @vip_users = Kaminari.paginate_array(@t).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipCard.cube_export_excel(@select_vip_users),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def amount
    @type = params[:type] || "pay_up"
    @total = current_user.vip_user_transactions.send(@type)
    @select_vip_user_transactions = @total.select('date(created_at) as created_date, sum(amount) as all_amount').group('date(created_at)').order("created_at desc")
    # @vip_user_transactions = @select_vip_user_transactions.page(params[:page])

    if params[:select_time].present?
      select_time = true 
      params[:start_time] = params[:select_time].split(' - ')[0]
      params[:end_time] = params[:select_time].split(' - ')[1]
    end
    @date = params[:created_date].present? ? params[:created_date] : "today"
    @today = Date.today
    @categories, @data, @start_time, @end_time, min_tick = cube_chart_data_for_datacube_amount(@total,@date,@today,select_time,params)

    @total_amounts = @total.sum(:amount)
    @today_amounts = @total.where("date(created_at) = ?",@today).sum(:amount)
    @yesterday_amounts = @total.where("date(created_at) = ?",@today-1.day).sum(:amount)
    @week_amounts = @total.one_weeks(@today).sum(:amount)
    @month_amounts = @total.one_months(@today).sum(:amount)
    @datetime = @start_time.to_s + " - " + @end_time.to_s

    @chart = cube_chart_base_line_for_datacube_amount(@categories, @data, min_tick, @type, @datetime) if @categories.present?

    t = @select_vip_user_transactions.to_a
    @t = [*@start_time..@end_time].map do |date|
      t.find { |u2| u2.created_date == date } || OpenStruct.new(created_date: date, all_amount: 0.00)
    end.reverse

    @vip_user_transactions = Kaminari.paginate_array(@t).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipUserTransaction.cube_export_excel(@select_vip_user_transactions, @type),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def point
    @total = current_user.point_transactions
    # @point_transactions = @total.group('date(created_at)').order("created_at desc").page(params[:page])
    point_transactions = @total.group('date(created_at)').order("id desc")

    if params[:select_time].present?
      select_time = true 
      params[:start_time] = params[:select_time].split(' - ')[0]
      params[:end_time] = params[:select_time].split(' - ')[1]
    end
    @date = params[:created_date].present? ? params[:created_date] : "today"
    @today = Date.today
    @categories, @data_up, @data_down, @data_all, @start_time, @end_time, min_tick = cube_chart_data_for_datacube_point(@total,@date,@today,select_time,params)

    @total_points = @total.in_point.sum(:points) - @total.out.sum(:points)
    @today_points = @total.in_point.where("date(created_at) = ?",@today).sum(:points)
    @yesterday_points = @total.in_point.where("date(created_at) = ?",@today-1.day).sum(:points)
    @week_points = @total.in_point.one_weeks(@today).sum(:points)
    @month_points = @total.in_point.one_months(@today).sum(:points)
    @datetime = @start_time.to_s + " - " + @end_time.to_s

    @chart = cube_chart_base_line_for_datacube_point(@categories, @data_up, @data_down, @data_all, min_tick, "#{@datetime}会员积分") if @categories.present?

    t = point_transactions.to_a
    @t = [*@start_time..@end_time].map do |date|
      t.find { |u2| u2.created_at.to_date == date } || OpenStruct.new(created_at: date)
    end.reverse

    @point_transactions = Kaminari.paginate_array(@t).page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(PointTransaction.cube_export_excel(@total),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  rescue => e
    redirect_to point_datacube_vips_path, alert: '操作错误'
  end

end