# -*- coding: utf-8 -*-
class Pro::HospitalDepartmentsController < Pro::HospitalBaseController
  before_filter :set_hospital, only: [:index, :new]
  before_filter :set_hospital_department, only: [:show, :edit, :update, :destroy, :doctors]

  def index
    @hospital_departments = @hospital.hospital_departments.order("sort asc")
    #@hospital_department = @hospital.hospital_departments.find_by_id(params[:id]) || @hospital.hospital_departments.new(parent_id: params[:parent_id].to_i)
  end

  def new
    @hospital_department = @hospital.hospital_departments.new(parent_id: params[:parent_id].to_i)
    @hospital_department.sort = params[:parent_id].present? ? @hospital_department.parent.children.count + 1 : @hospital_department.hospital.hospital_departments.root.count + 1

    render :partial=> "menu_name"
  end

  def create
    @hospital_department = @hospital.hospital_departments.new(params[:hospital_department])

    respond_to do |format|
      if @hospital_department.save
        format.html { redirect_to hospital_departments_path, notice: '添加成功' }
        format.json { render action: 'show', status: :created, location: @hospital_department }
      else
        format.html { redirect_to :back, alert: "添加失败: 科室名称不能为空" }
        format.json { render json: @hospital_department.errors, status: :unprocessable_entity }
      end
    end
  rescue => error
    redirect_to :back, alert: "添加失败:#{error}"
  end

  def edit
  end

  def update
    if @hospital_department.update_attributes(params[:hospital_department])
      redirect_to hospital_departments_path, notice: "更新成功"
    else
      redirect_to hospital_departments_path, notice: "更新失败"
    end
  end

  def destroy
    if @hospital_department.can_delete?
      @hospital_department.delete!
      redirect_to :back, notice: "删除成功"
    else
      redirect_to :back, alert: "科室有子分类或相关医生,不能删除"
    end
  end

  def doctors
    # render json: @hospital_department.doctors
    respond_to do |format|
      format.js
    end
  end

  private
  def set_hospital
    @hospital = current_site.hospital
  end

  def set_hospital_department
    @hospital_department = HospitalDepartment.find(params[:id])
  end

end
