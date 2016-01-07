# -*- coding: utf-8 -*-
class SupplierPrintsController < ApplicationController

  def index
    if params[:activity_id].to_i == 79
      @welomo_supplier_print = current_user.supplier_prints.welomo.first || current_user.supplier_prints.new(:machine_type =>3)
      return render 'welomo_index'
    else
      @small_supplier_print = current_user.supplier_prints.small.first || current_user.supplier_prints.new(:machine_type => 1)
      @big_supplier_print = current_user.supplier_prints.big.first || current_user.supplier_prints.new(:machine_type => 2)
    end
  end

  def create
    @supplier_print = SupplierPrint.new(params[:supplier_print])
    if @supplier_print.pic.blank? && !@supplier_print.welomo?
      redirect_to :back, alert: '二维码图片不能为空!'
    elsif @supplier_print.save!
      redirect_to :back, notice: '创建成功!'
    else
      render action: "new"
    end
  end

  def update
    @supplier_print = SupplierPrint.find(params[:id])
    if @supplier_print.pic.blank? && !@supplier_print.welomo?
      redirect_to :back, alert: '二维码图片不能为空!'
    elsif @supplier_print.update_attributes(params[:supplier_print])
      redirect_to :back, notice: '更新成功!'
    else
      render action: "edit"
    end
  end

  def activities
    if params[:activity_id]
      if params[:activity_id].to_i == 79
        @supplier_print_setting = current_user.supplier_print_settings.where(name: "微打印").first
        if @supplier_print_setting && @supplier_print_setting.activities.count == 2
        else
          @supplier_print_setting = current_user.wx_mp_user.build_activity_for_welomo_print_setting
        end
        render 'welomo'
      else
        @supplier_print_setting = current_user.supplier_print_settings.where(name: "微信打印").first
        if @supplier_print_setting && @supplier_print_setting.activities.count == 2
        else
          @supplier_print_setting = current_user.wx_mp_user.build_activity_for_supplier_print_setting
        end
        render 'activities'
      end
    else
      redirect_to dashboard_supplier_prints_url
    end
  end

  def dashboard
  end

  def update_activities
    @supplier_print_setting = SupplierPrintSetting.find(params[:id])
    if @supplier_print_setting.update_attributes(params[:supplier_print_setting])
      redirect_to :back, notice: '更新成功!'
    else
      redirect_to :back, alert: '关键词不能重复!'
    end
  end

  def update_pics
    @supplier_print = SupplierPrint.find(params[:id])
    @supplier_print.update_column("pic",params[:key])
    @supplier_print.connect_edit_webservice
    respond_to do |format|
      format.js {}
    end 
  end

end
