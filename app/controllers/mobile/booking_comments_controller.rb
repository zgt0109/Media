class Mobile::BookingCommentsController < Mobile::BaseController
  layout "mobile/booking"

  before_filter :set_booking_item, only: [:index, :new]
  before_filter :set_wx_user

  def index
  end

  def new
    #@wx_user_booking_comment =  @booking_comments.where(wx_user_id: session[:wx_user_id])
    @booking_comment = BookingComment.new(booking_item_id: params[:booking_item_id], wx_user_id: session[:wx_user_id])
  end

  def create
    @booking_comment = BookingComment.new(params[:booking_comment])
    if @booking_comment.save
      redirect_to new_mobile_booking_comment_path(supplier_id: @supplier.id, booking_item_id: params[:booking_comment][:booking_item_id])
    else
      redirect_to mobile_booking_comments_path(supplier_id: @supplier.id, booking_item_id: params[:booking_comment][:booking_item_id]), :notice => "评论失败"
    end
  end

  def set_booking_item
    @booking_item = @supplier.booking_items.find(params[:booking_item_id])
    @booking_comments = @booking_item.booking_comments.order("created_at desc")
  rescue
    render :text => '商品不存在'
  end

  def set_wx_user
    @wx_user = WxUser.find(session[:wx_user_id])
  end

end
