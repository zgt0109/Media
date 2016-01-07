class Biz::VipRecordsController < Biz::VipController
  include Biz::HighchartHelper
  
  before_filter :restrict_trial_supplier

  def index
    @total_vip_user_transactions = current_user.vip_user_transactions
    @search = @total_vip_user_transactions.search(params[:search])
    @vip_user_transactions = @search.page(params[:page]).order('created_at DESC')
    @direction = params[:search][:direction_type_eq] if params[:search]

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipUserTransaction.export_excel(@search.order('created_at DESC'),"money"),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def point
    @total_point_transactions = current_user.point_transactions
    @search = @total_point_transactions.search(params[:search])
    @point_transactions = @search.page(params[:page]).order('created_at DESC')
    @direction = params[:search][:direction_eq] if params[:search]

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipUserTransaction.export_excel(@search.page(params[:page_exl]).per(EXPORTING_COUNT).order('created_at DESC'),"point"),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def trend
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    @categories, @data_money, @data_point, @start, @count = chart_transaction_data_for_vip_record(current_user,@date,@today)
    @chart = chart_transaction_base_line_for_vip_record(@categories, @data_money, @data_point, VipUserTransaction::DATES[@date]) if @categories.present?
    @today_counts = current_user.vip_user_transactions.by_pay.where("date(created_at) = ?",@today).count
    @yesterday_counts = current_user.vip_user_transactions.by_pay.where("date(created_at) = ?",@today-1.day).count
    @total_counts = current_user.vip_user_transactions.by_pay.count
  end

end
