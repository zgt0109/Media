# -*- coding: utf-8 -*-
class Mobile::HospitalDoctorsController < Mobile::BaseController
  layout 'mobile/hospital'
  before_filter :set_branch

  def index
    department_id = params[:department_id] if params[:department_id]
    @page_class = "index"
    if department_id #搜索的情况
      @hospital_doctors = @hospital.hospital_departments.find(department_id).hospital_doctors.page(params[:page]).order(:sort)
    else
      @hospital_doctors = @hospital.hospital_doctors.page(params[:page]).per(5).order(:sort)
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @page_class = "detail"
    @hospital_doctor = @hospital.hospital_doctors.find(params[:id])
  end

  private

  def set_branch
    @hospital = @supplier.hospital
  end

end
