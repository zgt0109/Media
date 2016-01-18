class Pro::CarActivityNoticesController < ApplicationController
  # before_filter :check_car_shop

  def create
    @car_activity_notice = CarActivityNotice.new(params[:car_activity_notice])
    @car_activity_notice.activity.activityable = @car_activity_notice
    @car_activity_notice.activity.site = current_site
    @car_activity_notice.car_shop = current_site.car_shop
    if @car_activity_notice.activity.save && @car_activity_notice.save
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@car_activity_notice.errors.full_messages.join('，')}"
    end
  rescue => error
    redirect_to :back, notice: '保存失败'
  end

  def update
    @car_activity_notice = current_site.car_shop.car_activity_notices.find(params[:id])
    if @car_activity_notice.update_attributes(params[:car_activity_notice])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@car_activity_notice.errors.full_messages.join('，')}"
    end
  rescue => error
    return redirect_to :back, notice: '保存失败'
  end

  private
  def check_car_shop
    @car_shop = current_site.car_shop
    return redirect_to car_shops_path, notice: '请先设置微汽车基本信息' unless @car_shop
  end

end
