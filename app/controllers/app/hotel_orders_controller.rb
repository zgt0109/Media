module App
  class HotelOrdersController < BaseController
    layout 'app/hotel'
  
    def index
      @hotel_orders = HotelOrder.where(hotel_id: params[:aid], user_id: session[:user_id]).order("created_at desc").page(params[:page])
      respond_to do |format|
        format.html
        format.js{}
      end
    end

    def new
      @hotel_room_type = HotelRoomType.normal.where(id: params[:room_type_id],hotel_id: params[:aid]).first
      @hotel_branch = @hotel_room_type.hotel_branch
      @hotel_order = @hotel_room_type.hotel_orders.new(site_id: session[:site_id], hotel_id: params[:aid], user_id: session[:user_id], hotel_branch_id: @hotel_room_type.hotel_branch_id, hotel_room_type_id: params[:hotel_room_type_id], qty: 1)
      
      @max_available_qty = @hotel_room_type.hotel_room_settings.normal.where('date between ? and ?', params[:check_in_date] ,Date.parse(params[:check_out_date])-1.days).select('min(available_qty) available_qty').first.available_qty
    end
    
    def success
      @hotel_room_type = HotelRoomType.normal.where(id: params[:room_type_id],hotel_id: params[:aid]).first
      @hotel_branch = @hotel_room_type.hotel_branch
      @hotel_order = @hotel_room_type.hotel_orders.where(id: params[:hotel_order_id]).first
    end
    
    def show
      @hotel_order = HotelOrder.where(id: params[:id],hotel_id: params[:aid]).first
      @hotel_branch = @hotel_order.hotel_branch
      @hotel_room_type =@hotel_order.hotel_room_type
    end
    
    def create
      return redirect_to :back, notice: '无效请求' if session[:time].present? and session[:time].eql?(params[:time])
      session[:time] = params[:time] if params[:time].present?
      @hotel_room_type = HotelRoomType.normal.where(id: params[:room_type_id],hotel_id: params[:aid]).first
      return redirect_to :back, notice: '房间信息无效' if @hotel_room_type.nil?

      hotel_order = nil, notice = '预订失败'
      @hotel_order = @hotel_room_type.hotel_orders.new(params[:hotel_order])
      HotelOrder.transaction do
        (@hotel_order.check_in_date ... @hotel_order.check_out_date).each do |date|
          room_setting = @hotel_room_type.hotel_room_settings.normal.where(date: date).first
          room_setting ||=  @hotel_room_type.create_hotel_room_settings(date)
          booked_qty = room_setting.booked_qty + @hotel_order.qty
          available_qty = room_setting.available_qty - @hotel_order.qty
          if booked_qty <= room_setting.open_qty and available_qty >= 0
            room_setting.update_attributes(booked_qty: booked_qty, available_qty: available_qty)
          else
            notice = "#{date.strftime("%m月%d日")}房间已不够预订数#{@hotel_order.qty}间!"
            raise ActiveRecord::Rollback, "#{date.strftime("%m月%d日")}房间已不够预订数#{@hotel_order.qty}间!"
          end
        end
        hotel_order = @hotel_order.save
      end
      if hotel_order
        # 微酒店订房成功
        if @hotel_order.try(:hotel_branch).try(:mobile).present?
          # begin
          #   sms_content = "微酒店订房通知：用户“#{@hotel_order.name}”电话：#{@hotel_order.mobile} 于 #{@hotel_order.created_at} 预定了《#{@hotel_order.hotel_room_type.try(:name)}》房间，所属分店：#{@hotel_order.hotel_branch.try(:name)}"
          #   @site.account.send_message(@hotel_order.hotel_branch.mobile, sms_content, "酒店")
          # rescue Exception => e
          #   Rails.logger.error "微酒店订房通知短信发送失败：#{e}"
          # end
        end        
        redirect_to success_app_hotel_orders_url(room_type_id: params[:room_type_id],hotel_order_id: @hotel_order.id, aid: params[:aid], check_in_date: params[:check_in_date], check_out_date: params[:check_out_date]), notice: '预订成功'
      else
        redirect_to :back, notice: notice
      end
    end
  
  end
end

