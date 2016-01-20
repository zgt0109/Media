class Pro::BookingItemsController < Pro::BookingBaseController
  before_filter :set_booking
  before_filter :set_booking_item, only: [:show, :edit, :update, :destroy]

  def index
    @booking_items = Kaminari.paginate_array(@booking.show_items(params)).page(params[:page])
    @booking_categories_selects = @booking.multilevel_menu params
    3.times{|index| @booking_categories_selects.push([index + 1, []]) unless @booking_categories_selects[index].present?}
  end

  def new
    @booking_item = current_site.booking_items.new
    @booking_item_picture = @booking_item.booking_item_pictures.new
    @booking_categories_selects = @booking.multilevel_menu params
    @booking_categories_selects = [[1, []]] unless @booking_categories_selects.present?
  end


  def create
    @booking_item = current_site.booking_items.new(params[:booking_item])
    if @booking_item.save
      redirect_to booking_items_path, notice: '保存成功'
    else
      flash[:alert] = "保存失败"
      @booking_categories_selects = @booking.multilevel_menu params
      @booking_categories_selects = [[1, []]] unless @booking_categories_selects.present?
      render action: 'new'
    end
  end

  def edit
    @booking_categories_selects = @booking_item.multilevel_menu params
    @booking_categories_selects = [[1, []]] unless @booking_categories_selects.present?
  end


  def update
    if @booking_item.update_attributes(params[:booking_item])
      redirect_to booking_items_path, notice: '保存成功'
    else
      flash[:alert] = "更新失败"
      @booking_categories_selects = @booking.multilevel_menu params
      @booking_categories_selects = [[1, []]] unless @booking_categories_selects.present?
      render action: 'edit'
    end
  end

  def destroy
    respond_to do |format|
      if @booking_item.destroy
        format.html { redirect_to :back, notice: '删除成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, alert: '删除失败' }
        format.json { render json: @booking_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_booking
    @booking = current_site.booking
    @booking_categories = current_site.booking_categories
  end

  def set_booking_item
    @booking_item = BookingItem.where(id: params[:id]).first
    return redirect_to booking_items_path, alert: '商品不存在或已删除' unless @booking_item
  end

end
