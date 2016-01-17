class QrcodeChannelStatisticsController < ApplicationController

  def index
    @total_qrcode_logs = current_site.qrcode_logs.normal
    @total_qrcode_users = current_site.qrcode_users.normal
    total = current_site.qrcode_channels.normal
    @qrcode_channels = total.page(params[:page])
    select_time = true if params[:start_time].present? && params[:end_time].present?
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    @categories, @series, @start_time, @end_time, @count, @min_tick = QrcodeChannel.chart_data(total,@date,@today,select_time,params,@total_qrcode_logs,@qrcode_channels)
    # @categories, @series, @start_time, @end_time, @count, @min_tick = QrcodeChannel.chart_data(total,@date,@today,select_time,params,@total_qrcode_logs)
    @chart = QrcodeChannel.chart_base_line(@categories, @series, @min_tick) if @categories.present?
    @categories_amount, @series_amount, start_time, end_time, @amount, @min_tick_amount = QrcodeChannel.chart_data_amount(total,@date,@today,select_time,params,@qrcode_channels)
    @chart_amount = QrcodeChannel.chart_base_line_amount(@categories_amount, @series_amount, @min_tick_amount) if @categories_amount.present?
  end

  private

  def mp_user_is_sync
    return redirect_to profile_path, alert: '服务号才有此功能' unless current_site.wx_mp_user.is_sync?
  end
end