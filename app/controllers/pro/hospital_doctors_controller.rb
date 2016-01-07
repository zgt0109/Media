# -*- coding: utf-8 -*-
class Pro::HospitalDoctorsController < Pro::HospitalBaseController

  def index
    @search = current_user.hospital.hospital_doctors.search(params[:search])
    @hospital_doctors = @search.page(params[:page]).order("created_at desc")
  end

  def new
    @hospital_doctor = current_user.hospital.hospital_doctors.new
    @hospital_job_title = current_user.hospital.hospital_job_titles.new
    @hospital_department = current_user.hospital.hospital_departments.new
    sort = current_user.hospital.hospital_doctors.maximum("sort") || 0
    @hospital_doctor.sort = sort + 1
  end

  def edit
    @hospital_doctor = current_user.hospital.hospital_doctors.find(params[:id])
    @hospital_job_title = current_user.hospital.hospital_job_titles.new
    @hospital_department = current_user.hospital.hospital_departments.new
  end

  def update
    @hospital_doctor = current_user.hospital.hospital_doctors.find(params[:id])
    if @hospital_doctor.update_attributes(params[:hospital_doctor])
      redirect_to :hospital_doctors, :notice => "更新成功"
    else
      redirect_to :back, :alert => "更新失败"
    end
  end

  def toggle
    begin
      @hospital_doctor = HospitalDoctor.find(params[:id])
      @hospital_doctor.toggle_is_online
      render text: 'ok'
    rescue
      render text: 'error'
    end
  end

  def create
    @hospital_doctor = current_user.hospital.hospital_doctors.new(params[:hospital_doctor])
    if @hospital_doctor.save
      redirect_to :hospital_doctors, :notice => "保存成功"
    else
      @hospital_job_title = current_user.hospital.hospital_job_titles.new
      @hospital_department = current_user.hospital.hospital_departments.new
      flash[:alert] = "保存失败：#{@hospital_doctor.errors.values.join(' 和 ')}。"
      render :new
    end
  end

  def destroy
    @hospital_doctor = current_user.hospital.hospital_doctors.find(params[:id])
    if @hospital_doctor.doctor_watches.count > 0
      return redirect_to :back, notice: "该医生已经有排班， 无法删除"
    end
    @hospital_doctor.delete!
    flash[:notice] = "删除成功"
    redirect_to :back
  end

end
