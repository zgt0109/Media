class Mobile::BookingCommentsController < Mobile::BaseController
  layout "mobile/booking"

  before_filter :set_booking_item, only: [:index, :new]

  def new
    @booking_comment = BookingComment.new(booking_item_id: params[:booking_item_id], user_id: session[:user_id])
  end

  def create
    @booking_comment = BookingComment.new(params[:booking_comment])
    if @booking_comment.save
      redirect_to new_mobile_booking_booking_comment_url(site_id: @site.id, booking_item_id: params[:booking_comment][:booking_item_id])
    else
      redirect_to mobile_booking_booking_comments_url(site_id: @site.id, booking_item_id: params[:booking_comment][:booking_item_id]), :notice => "评论失败"
    end
  end

  def set_booking_item
    @booking = @site.bookings.where(id: params[:booking_id]).first
    @booking_item = @booking.booking_items.find(params[:booking_item_id])
    @booking_comments = @booking_item.booking_comments.order("created_at desc")
  rescue
    render :text => '商品不存在'
  end

end
