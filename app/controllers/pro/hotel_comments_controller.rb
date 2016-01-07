class Pro::HotelCommentsController < Pro::HotelsBaseController
  before_filter :check_hotel
  before_filter :set_hotel_comment, only: [:show, :edit, :update, :destroy]

  def index

    conds, conds_h = [], {}
    unless params[:q].blank?
      conds << "hotel_comments.#{params[:field]} LIKE :q"
      conds_h[:q] = "%#{params[:q]}%"
    end

    @total_hotel_comments = @hotel.hotel_comments.where("status > ?", -1).where(conds.join(' AND '), conds_h).order("created_at desc")
	  @search = @total_hotel_comments.search(params[:search])
		@hotel_comments = @search.page(params[:page])

  end

  def show
    render layout: 'application_pop'
  end

  def update
    if @hotel_comment.update_attributes(params[:hotel_comment])
      flash[:notice] = "回复成功"
      render inline: "<script>window.parent.location.href = '#{hotel_comments_url}';</script>"
    else
      flash[:alert] = '回复失败'
      render 'show', layout: 'application_pop'
    end
  end

  def destroy
    if @hotel_comment.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def set_hotel_comment
    @hotel_comment = @hotel.hotel_comments.where(id: params[:id]).first
    return  redirect_to hotel_comments_url, alert: '评论不存在或已删除' unless @hotel_comment
  end


end

