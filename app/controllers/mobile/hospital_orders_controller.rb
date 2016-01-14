class Mobile::HospitalOrdersController < Mobile::BaseController
  layout 'mobile/hospital'

  before_filter :find_hospital
  
  def index
    @page_class = "detail"
    @hospital_orders = @wx_user.hospital_orders.order('id desc')
  end
  
  def new
    @page_class = "order"
    @hospital_doctor = @hospital.hospital_doctors.find(params[:id])
    @hospital_order = @hospital_doctor.hospital_orders.new(user_id: @user.id)
    @hospital_orders = @wx_user.hospital_orders.order('id desc')
  end

  def create
    @hospital_doctor = @hospital.hospital_doctors.find(params[:id])
    @hospital_order = @hospital_doctor.hospital_orders.new(params[:hospital_order])
    @hospital_order.booking_at = "#{params[:day]} #{params[:noon]}"

    if @hospital_doctor.hospital_orders.where(booking_at: (@hospital_order.booking_at.to_date)..(@hospital_order.booking_at.to_date+1.day)).count >= @hospital_doctor.limit_register_count and @hospital_doctor.limit_register_count != -1
      redirect_to mobile_hospital_doctors_url, notice: "对不起，预约人数已满！"
    elsif @hospital_doctor.hospital_orders.where(booking_at: (@hospital_order.booking_at.to_date)..(@hospital_order.booking_at.to_date+1.day), user_id: @user.id).first
      redirect_to mobile_hospital_doctors_url, notice: "对不起，您已经预约！"
    elsif @hospital_order.save
      redirect_to mobile_hospital_orders_url, notice: "预约成功"
    else
      render 'new', alert: '预约失败'
    end
  end

  private

  def find_hospital
    @hospital = @site.hospital
  end

end

