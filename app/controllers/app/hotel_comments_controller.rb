module App
  class HotelCommentsController < BaseController
    layout 'app/hotel'

    def index      
      @hotel_branch = HotelBranch.where(id: params[:branch_id], hotel_id: params[:aid]).first
      @hotel_comments = @hotel_branch.hotel_comments.where('status > ?', HotelComment::DELETED).order("created_at desc").page(params[:page])
      respond_to do |format|
        format.html
        format.js{}
      end
    end
    
    def new
      @hotel = Hotel.where(id: params[:aid], wx_mp_user_id: session[:wx_mp_user_id]).first
      @hotel_order = @hotel.hotel_orders.where(id: params[:oid]).first
      @hotel_branch = @hotel.hotel_branches.where(id: @hotel_order.try(:hotel_branch_id)).first
      return redirect_to :back, notice: '参数错误' if @hotel.nil? or @hotel_branch.nil?

      @hotel_comment = @hotel_branch.hotel_comments.new(hotel_id: params[:aid], wx_user_id: session[:wx_user_id], supplier_id: session[:supplier_id], wx_mp_user_id: session[:wx_mp_user_id], hotel_order_id: params[:oid])
    end
    
    def create
      return redirect_to :back, notice: '无效请求' if session[:comment_time].present? and session[:comment_time].eql?(params[:comment_time])
      session[:comment_time] = params[:comment_time] if params[:comment_time].present?
      @hotel_branch = HotelBranch.where(id: params[:hotel_comment][:hotel_branch_id], hotel_id: params[:aid]).first
      @hotel_comment = @hotel_branch.hotel_comments.new(params[:hotel_comment])

      if @hotel_comment.save
        redirect_to app_hotel_comments_path(aid: params[:aid], wxmuid: session[:wx_mp_user_id], branch_id: params[:hotel_comment][:hotel_branch_id], source: params[:source]), notice: '评论成功'
      else
        redirect_to :back, notice: '评论失败'
      end
    end
    
  end
end