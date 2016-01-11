class Biz::GroupCategoriesController < Biz::GroupBaseController
  include Biz::GroupCategoriesHelper

  before_filter :set_group, only: [:index, :new, :move_higher, :move_lower]
  before_filter :set_group_category, only: [:show, :edit, :update,
                                           :destroy, :move_higher, :move_lower]
  def index
    @current_titles << '分类管理'
    @group_categories = @group.group_categories
  end



  def new
    @group_category = @group.group_categories.new(parent_id: params[:parent_id].to_i)
    render layout: 'application_pop'
  end

  def create
    @group_category = GroupCategory.new(params[:group_category])
    if @group_category.save
      render action: 'edit_result', layout: 'application_pop'
    else
      render action: 'new', layout: 'application_pop'
    end
  end


  def edit
    render layout: 'application_pop'
  end


  def update
    if @group_category.update_attributes(params[:group_category])
      # redirect_to group_categories_url, notice: "更新成功"
      render action: 'edit_result', layout: 'application_pop'
    else
      render action: 'edit', layout: 'application_pop'
    end
  end

  def move_higher
    higher_category = @group_category.try(:higher_item)
    if higher_category.present?
      sorts = [@group_category.sort, higher_category.sort]
      higher_category.set_list_position(sorts.first)
      @group_category.set_list_position(sorts.last)
    else
      @group_category.try(:move_to_top)
    end
    @group_category.try(:move_higher)

    render json: {result: 'sucess', remark: '移动成功', data: JSON.parse(category_tree_data(@group))}
  #rescue => error
  #  render json: {result: 'failure', remark: '移动失败'}
  end

  def move_lower
    lower_category = @group_category.try(:lower_item)
    if lower_category.present?
      sorts = [@group_category.sort, lower_category.sort]
      lower_category.set_list_position(sorts.first)
      @group_category.set_list_position(sorts.last)
    else
      @group_category.try(:move_to_bottom)
    end
    render json: {result: 'sucess', remark: '移动成功', data: JSON.parse(category_tree_data(@group))}
  #rescue => error
  #  render json: {result: 'failure', remark: '移动失败'}
  end

  def destroy
    if @group_category.group_items.count > 0
      redirect_to groups_path(anchor: "tab-2"),  notice: "菜单下面有商品， 不能删除"
    elsif @group_category.has_children?
      redirect_to groups_path(anchor: "tab-2"),  notice: "菜单下面有子菜单， 不能删除"
    else
      @group_category.destroy
      respond_to do |format|
        format.html { redirect_to groups_path(anchor: "tab-2"),  notice: "删除成功" }
        format.json { head :no_content }
      end
    end

  end



  private

  def set_group
    @group = current_site.group
    @activity =  @group.activity
  end

  def set_group_category
    @group_category = GroupCategory.find(params[:id])
  end
end
