class Biz::GroupItemsController < Biz::GroupBaseController
  before_filter :set_group
  before_filter :set_group_item, only: [:show, :edit, :update, :destroy]

  def new
    @current_titles << '商品管理'
    @group_item = @group.group_items.new(group_type: 1)
  end

  def create
    @group_item = @group.group_items.new(params[:group_item])
    respond_to do |format|
      if @group_item.save
        format.html { redirect_to items_groups_path, notice: '添加成功' }
        format.json { render json: @group_item, status: :created, location: @service }
      else
        format.html { render action: "new" }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @group_item.update_attributes(params[:group_item])
        format.html { redirect_to items_groups_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '更新失败' }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @group_item.delete!
        format.html { redirect_to :back, notice: "下架成功" }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: "下架失败" }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_group
    @group = current_site.group
    @group_categories = current_site.group_categories
    @activity =  @group.activity
  end

  def set_group_item
    @group_item = GroupItem.find(params[:id])
  end
end
