class Pro::TripTicketCategoriesController < Pro::TripBaseController
  before_filter :get_wx_mp_user, :set_seo, :require_industry
  before_filter :set_trip_ticket_categories
  before_filter :set_trip_ticket_category, only: [:edit, :update, :destroy, :update_position]

  def index
  end
  
  def new
  	@category = @categories.new(parent_id: params[:parent_id])
  end

  def create
  	@category = @categories.new(params[:trip_ticket_category])
  	if @category.save
  	  redirect_to trip_ticket_categories_path, notice: '保存成功'
  	else
  	  redirect_to :back, alert: '保存失败'
  	end
  end

  def edit
  end

  def update
  	if @category.update_attributes(params[:trip_ticket_category])
  	  redirect_to trip_ticket_categories_path, notice: '保存成功'
  	else
  	  redirect_to :back, alert: '保存失败'
  	end
  end

  def destroy
  	if @category.destroy
  	  redirect_to trip_ticket_categories_path, notice: '删除成功'
  	else
  	  redirect_to :back, alert: '删除失败'
  	end
  end

  def update_position
    if params[:type] == "up"
      @category.move_higher
    elsif params[:type] == "down"
      @category.move_lower  
    end
    render json: {result: 'success', id: @category.id}
  end

  private

  def set_trip_ticket_categories
  	@categories = current_site.trip_ticket_categories
  end

  def set_trip_ticket_category
  	@category = @categories.where(id: params[:id]).first
    redirect_to trip_ticket_categories_path, alert: '分类不存在或已删除' unless @category
  end

end
