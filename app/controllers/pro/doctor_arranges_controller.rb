# -*- coding: utf-8 -*-
class Pro::DoctorArrangesController < Pro::HospitalBaseController

  def index
    @search = current_site.hospital.doctor_arranges.search(params[:search])
    @doctor_arranges = @search.page(params[:page]).order("created_at desc")
  end

  def new
    @doctor_arrange = current_site.hospital.doctor_arranges.new
    @doctor_arranges = current_site.hospital.doctor_arranges

    @second_level = current_site.hospital.hospital_departments.normal
    to_remove = Array.new
    @second_level.each do |d|
      puts d.name
      if  d.has_children?
        to_remove << d
      else

      end
    end
    to_remove.each do |r|
      @second_level.delete_if {|s| s.id == r.id}
    end
    puts @second_level.count
  end

  def edit
    @doctor_arrange = current_site.hospital.doctor_arranges.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @doctor_arrange = current_site.hospital.doctor_arranges.find(params[:id])
    @doctor_arrange.destroy
    respond_to do |format|
      format.js
    end
  end

  def create
    @is_v = true
    @flash_arranges = Array.new
    weeks = params[:weeks].to_a
    if weeks.include?("-1") # select all
      for i in 0..6
        doctor_arrange = current_site.hospital.doctor_arranges.new(params[:doctor_arrange])
        doctor_arrange.week = i
        doctor_arrange.save!
        @flash_arranges << doctor_arrange
        if doctor_arrange.has_multi || doctor_arrange.is_duplicate
          @is_v = false
        else
          doctor_arrange.create_doctor_watches 2
        end
      end
    else
      for i in weeks
        doctor_arrange = current_site.hospital.doctor_arranges.new(params[:doctor_arrange])
        doctor_arrange.week = i
        doctor_arrange.save!
        @flash_arranges << doctor_arrange
        if doctor_arrange.has_multi || doctor_arrange.is_duplicate
          @is_v = false
        else
          doctor_arrange.create_doctor_watches 2
        end
      end
    end

    @flash_arranges.each do |a|
      if @is_v
        a.update_column("is_success", 2)
      else
        a.destroy
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def update
    # 1. check doctor arrange has_multi (doctor_id week start time end time)
    # 2. if has direct back else go to update self method
    @is_s = true
    @doctor_arrange = current_site.hospital.doctor_arranges.find(params[:id])
    temp_doctor_arrange = DoctorArrange.new(params[:doctor_arrange])
    temp_doctor_arrange.hospital_doctor_id = @doctor_arrange.hospital_doctor_id
    temp_doctor_arrange.time_limit = @doctor_arrange.time_limit
    temp_doctor_arrange.id = @doctor_arrange.id
    @doctor_arrange.update_column("is_success", 3) # temp status
    if temp_doctor_arrange.is_duplicate
      @is_s = false
      @doctor_arrange.update_column("is_success", 2) # reset
    elsif temp_doctor_arrange.update_self
      @doctor_arrange.update_attributes(params[:doctor_arrange])
    else
      @is_s = false
    end

    respond_to do |format|
      format.js
    end
  end

end
