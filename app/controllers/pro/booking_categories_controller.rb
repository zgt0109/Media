class Pro::BookingCategoriesController < Pro::BookingBaseController
  before_filter :set_booking_category, only: [:show, :edit, :update, :destroy, :update_sorts]
  before_filter :set_booking_categories , only: [:index]

  def new
    @booking_category = @booking.booking_categories.new(parent_id: params[:parent_id].to_i)
  end

  def create
    @booking_category = @booking.booking_categories.new(params[:booking_category])
    respond_to do |format|
      if @booking_category.save
        format.html { redirect_to booking_categories_path, notice: '添加成功' }
        format.json {head :no_content}
      else
        format.html { redirect_to :back, alert: "添加失败:#{@booking_category.errors.full_messages}" }
        format.json { render json: @booking_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @booking_category.update_attributes(params[:booking_category])
        format.html { redirect_to booking_categories_path, notice: '更新成功' }
        format.json {head :no_content}
      else
        format.html { redirect_to :back, alert: "更新失败:#{@booking_category.errors.full_messages}" }
        format.json { render json: @booking_category.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @booking_category.booking_items.count > 0
      redirect_to :back,  notice: "菜单下面有商品， 不能删除"
    elsif @booking_category.has_children?
      redirect_to :back,  notice: "菜单下面有子菜单， 不能删除"
    else
      @booking_category.destroy
      respond_to do |format|
        format.html { redirect_to booking_categories_path,  notice: "删除成功" }
        format.json { head :no_content }
      end
    end
  end

  def update_sorts
    #1:置顶， -1:置底
    if @booking_category.parent
      @booking_categories = @booking_category.parent.children.order(:sort)
    else
      @booking_categories = @booking.booking_categories.root.order(:sort)
    end

    index = @booking_categories.to_a.index(@booking_category)
    @booking_categories.each_with_index{|category, index| category.sort = index + 1}

    if params[:type] == "up"

      unless index - 1 >= 0
        render :text => 1
        return
      end

      current_sort = @booking_categories[index].sort
      up_sort = @booking_categories[index - 1].sort

      @booking_categories[index].sort = current_sort - 1
      @booking_categories[index - 1].sort = up_sort + 1
    else
      unless @booking_categories[index + 1]
        render :text => -1
        return
      end

      current_sort = @booking_categories[index].sort
      down_sort = @booking_categories[index + 1].sort

      @booking_categories[index].sort = current_sort + 1
      @booking_categories[index + 1].sort = down_sort - 1
    end
    @booking_categories.each do |category|
      category.update_column('sort', category.sort)
    end
    render :partial=> "sub_menu", :collection => @booking_categories.sort{|x, y| x.sort<=>y.sort}, :as =>:sub_menu
  end

  private

  def set_booking_category
    @booking_category = BookingCategory.where(id: params[:id]).first
    return redirect_to booking_categories_path, alert: '分类不存在或已删除' unless @booking_category
  end

  def set_booking_categories
    @booking_categories = @booking.booking_categories
  end

end
