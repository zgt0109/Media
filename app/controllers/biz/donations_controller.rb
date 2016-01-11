# -*- coding: utf-8 -*-
class Biz::DonationsController < ApplicationController

  def index
    @search = current_site.donations.search(params[:search])
    @donations = @search.page(params[:page])
  end

  #new activity
  def activity
    @activity = current_site.activities.new(activity_type_id: ActivityType::DONATION)
  end

  def update_activity
    unless params[:aid].blank?
      @activity = current_site.activities.find(params[:aid])
      @activity.update_attributes(params[:activity])
    else
      @activity = current_site.activities.new(params[:activity])
    end
    if @activity.save!
      return redirect_to list_activities_donations_url,  notice: '保存成功'
    else
      return redirect_to list_activities_donations_url,  notice: '保存失败'
    end
  end

  def edit_activity
    @activity = current_site.activities.where(id: params[:aid]).first
    render 'activity'
  end

  def update
    @donation = current_site.donations.find(params[:id])
    if @donation.update_attributes params[:donation]
      return redirect_to donations_url, notice: "更新成功"
    else
      return redirect_to donations_url, notice: "关键词不能重复!"
    end
  end

  def new
    @donation = current_site.donations.new
  end

  def list_activities
    @activities = current_site.activities.where(activity_type_id: 53).page(params[:page])
  end

  def create
    @donation = current_site.donations.build params[:donation]
    @donation.status = 1 #默认进行中

    if @donation.save
      return redirect_to donations_url, notice: "保存成功"
    else
      return redirect_to donations_url, notice: "关键词不能重复!"
    end
  end

  def edit
    @donation = current_site.donations.find(params[:id])
  end

  def orders
    @search = @current_site.donation_orders.order("donation_orders.created_at DESC").search(params[:search])
    @donation_orders = @search.page(params[:page])
    respond_to do |format|
      format.html
      format.xls {
        options = {
          header_columns: ['活动名称', '姓名', '手机号码', '捐赠金额', '捐赠时间', '支付订单号', '地址'],
          only:     [:donation_name, :name, :mobile, :fee, :created_at, :trade_no, :address]
        }
        send_data(@search.all.to_xls(options)) }
    end
  end

  def start
    @donation = current_site.donations.find(params[:id])
    @donation.update_column("status", 1)
    respond_to do |format|
      format.js
    end
  end

  def stop
    @donation = current_site.donations.find(params[:id])
    @donation.update_column("status", -1)
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @donation = current_site.donations.find(params[:id])
    if @donation.donation_orders.count > 0 #有过捐款了
      return redirect_to donations_url, notice: "该项目已经有捐款了, 不能删除"
    end
    @donation.destroy
    redirect_to donations_url, notice: "删除成功"
  end
end
