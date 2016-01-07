# -*- coding: utf-8 -*-
class Pro::DoctorWatchesController < Pro::HospitalBaseController

  def index
    if current_user.shop.blank? || current_user.shop.shop_branches.used.count == 0
      return redirect_to :back, alert: '请先添加门店'
    end 
    @search = current_user.hospital.doctor_watches.search(params[:search])
    @doctor_watches = @search.page(params[:page]).order("created_at desc")
  end


  def edit
    @doctor_watch = current_user.hospital.doctor_watches.find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def stop
    @doctor_watch = current_user.hospital.doctor_watches.find(params[:id])
    @doctor_watch.stop!
    return redirect_to :back, notice: "操作成功"
  end

  def start
    @doctor_watch = current_user.hospital.doctor_watches.find(params[:id])
    @doctor_watch.start!
    return redirect_to :back, notice: "操作成功"
  end

  def update
    @is_s = true
    @doctor_watch = current_user.hospital.doctor_watches.find(params[:id])
    temp_doctor_watch = DoctorWatch.new(params[:doctor_watch])
    temp_doctor_watch.hospital_doctor_id = @doctor_watch.hospital_doctor_id
    @doctor_watch.update_column("is_success", 3)
    if temp_doctor_watch.is_multi
      @is_s = false
    else
      current_user.hospital.doctor_watches.find(params[:id]).update_attributes(params[:doctor_watch])
    end
    @doctor_watch.update_column("is_success", 2)
    respond_to do |format|
      format.js
    end
  end

end
