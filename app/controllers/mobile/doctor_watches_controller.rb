# -*- coding: utf-8 -*-
class Mobile::DoctorWatchesController < Mobile::BaseController

  def index
    @hospital_doctor = HospitalDoctor.find(params[:doctor_id])
    #只取一星期以前的
    @doctor_watches = @hospital_doctor.doctor_watches.where("doctor_watches.start_time < ?", Time.now.ago(-7.days))
    fd = @hospital_doctor.doctor_watches.where("doctor_watches.start_time < ?", Time.now.ago(-7.days)).maximum("end_time")
    if fd
      final_date = fd.to_date
    else
      return redirect_to :back, notice: "该医生没有任何排班信息"
    end
    validate_watches = @hospital_doctor.doctor_watches.where(status: 1).where("doctor_watches.start_time >= ?", Time.now.to_date).where("doctor_watches.start_time < ?", Time.now.ago(-7.days))
    validate_watches.each do |v|
      if v.is_full
        validate_watches.delete_if {|vw| vw.id == v.id}
      end
    end
    another_array = validate_watches
    ordered_days = validate_watches.order("start_time")
    near_day = Time.now.to_date
    validate_watches.order("start_time").each do |v|
      if v.is_full

      else
        near_day = v.start_time.to_date
        break
      end
    end
    @default_date = (Time.now.to_date - near_day).to_i
    sd = Time.now.to_date
    @array = Array.new
    @diff_date = (final_date - sd).to_i
    sd.upto(final_date) { |date|
      ret = -1 #不上班
      stop_watch_count = 0
      full_watch_count = 0
      one_day_watches = Array.new      
      @doctor_watches.each do |watch| # status of one day 
        if watch.end_time.to_date == date
          one_day_watches << watch
        end
        one_day_watches.each do |w|
          if w.is_full
            full_watch_count += 1
          end
          if w.stop?
            stop_watch_count += 1
          end
        end
      end
        if (stop_watch_count + full_watch_count >= one_day_watches.count)
          if full_watch_count > 0
            ret = 1 # full
          else
            ret = -1
          end
        else
          ret = 0 # avaiable
        end
      @array.push(ret) # one day's status
    }
    @doctor_arrange_item = DoctorArrangeItem.new
    render layout: false
  end

  def items
    return render_404 if params[:time].nil?
    date = Date.parse(params[:time])
    @doctor_watches = HospitalDoctor.find(params[:doctor_id]).doctor_watches
    @doctor_watches = @doctor_watches.where('doctor_watches.end_time BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day).where(status: 1).all
    @doctor_watches.each do |v|
      puts "#{v.start_time} - #{v.end_time}"
      if v.is_full
        @doctor_watches.delete_if {|vw| vw.id == v.id}
      end
    end
    respond_to do |format|
      format.js {}
    end
  end

end
