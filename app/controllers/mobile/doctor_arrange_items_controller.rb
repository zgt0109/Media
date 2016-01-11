# -*- coding: utf-8 -*-
class Mobile::DoctorArrangeItemsController < Mobile::BaseController
  layout 'mobile/hospital'

  def create
    @doctor_arrange_item = DoctorArrangeItem.new(params[:doctor_arrange_item])
    @doctor_arrange_item.user_id = session[:user_id]
    @doctor_arrange_item.status = 1
    if @doctor_arrange_item.doctor_watch.is_full
      return redirect_to :back, notice: "排班已满!"
    end
    @doctor_arrange_item.doctor_watch.doctor_arrange_items.each do |item|
      if item.user_id == session[:user_id].to_i
        return redirect_to :back, notice: "不能重复挂号!"
      end
    end
    if @doctor_arrange_item.save!
      return redirect_to mobile_doctor_arrange_item_url(site_id: session[:site_id], id: @doctor_arrange_item)
    end
  end

  def show
    @doctor_arrange_item = DoctorArrangeItem.find(params[:id])
  end

  def new
    @doctor_arrange_item = DoctorArrangeItem.new(params[:doctor_arrange_item])
    @doctor_watch = @doctor_arrange_item.doctor_watch
    return render_404 if @doctor_watch.nil?
  end

  def my_items
    @items = DoctorArrangeItem.where(user_id: session[:user_id]).order("created_at desc")
  end

end
