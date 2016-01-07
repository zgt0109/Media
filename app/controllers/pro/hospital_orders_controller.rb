# -*- coding: utf-8 -*-
class Pro::HospitalOrdersController < Pro::HospitalBaseController
  before_filter :set_hospital_order, only: [:cancele, :complete, :show]

  def index
    #@search = current_user.hospital_orders.search(params[:search])
    #@hospital_orders = @search.page(params[:page]).order("created_at desc")
    @search = current_user.hospital.doctor_arrange_items.search(params[:search])
    @doctor_arrange_items = @search.page(params[:page]).order("created_at desc")
  end

  def show
    render layout: 'application_pop'
  end

  def complete
    @doctor_arrange_item.complete!
    redirect_to hospital_orders_url, notice: '已就诊'
  end

  def cancele
    @doctor_arrange_item.cancel!
    redirect_to hospital_orders_url, notice: '已取消'
  end

  def history
    @search = current_user.hospital_orders.search(params[:search])
    @hospital_orders = @search.page(params[:page]).order("created_at desc")
  end

  private
  def set_hospital_order
    #@hospital_order = HospitalOrder.where(id: params[:id]).first
    @doctor_arrange_item = DoctorArrangeItem.where(id: params[:id]).first
  end
end
