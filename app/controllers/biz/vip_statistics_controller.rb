class Biz::VipStatisticsController < Biz::VipController
  include Biz::HighchartHelper

  def index
    @total_vip_users = current_user.vip_users.visible.normal_and_freeze.select('date(created_at) as created_date, count(*) as count, 1 as total_count').group('date(created_at)').order("created_at desc")
    @search = @total_vip_users.search(params[:search])
    @vip_users = @search.page(params[:page]).per(20)

    last_count = current_user.vip_users.visible.normal_and_freeze.where('date(created_at) <= ?', @vip_users.last.try(:created_date)).count

    last_vip = nil

    @vip_users.reverse.each do |v|
      v.total_count = last_vip ? last_vip.total_count + v.count : last_count
      last_vip = v
    end

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipCard.export_excel(@vip_users),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  rescue => e
    redirect_to vip_statistics_path, alert: '操作错误'
  end

  def show_chart
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    # @vip_users = current_user.vip_users.visible.normal.send(@date, today).select('date(created_at) as created_date, count(*) as count').group('date(created_at)').order("created_at asc")
    @categories, @data, @start, @count = chart_data_for_vip_card(current_user,@date,@today)
    @chart = chart_base_line_for_vip_card(@categories, @data, VipCard::DATES[@date]) if @categories.present?
    @today_counts = current_user.vip_users.visible.normal_and_freeze.where("date(created_at) = ?",@today).count
    @yesterday_counts = current_user.vip_users.visible.normal_and_freeze.where("date(created_at) = ?",@today-1.day).count
    @total_counts = current_user.vip_users.visible.normal_and_freeze.count
  end

end