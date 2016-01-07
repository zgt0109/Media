class Biz::GroupItemsController < Biz::GroupBaseController
  before_filter :set_group
  before_filter :set_group_item, only: [:show, :edit, :update, :destroy]

  def new
    @current_titles << '商品管理'
    @group_item = @group.group_items.new(wx_mp_user_id: @group.wx_mp_user_id, group_type: 1)
  end


  def create
    @group_item = @group.group_items.new(params[:group_item])
    respond_to do |format|
      if @group_item.save
        format.html { redirect_to groups_path(anchor: "tab-3"), notice: '添加成功' }
        format.json { render json: @group_item, status: :created, location: @service }
      else
        format.html { render action: "new" }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @group_item.update_attributes(params[:group_item])
        format.html { redirect_to groups_path(anchor: "tab-3"), notice: '更新成功' }
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
        msg = @group_item.deleted? ? "下架" : "上架"
        format.html { redirect_to groups_path(anchor: "tab-3"), notice: "#{msg}成功" }
        format.json { head :no_content }
      else
        format.html { redirect_to groups_path(anchor: "tab-3"), notice: "#{msg}失败" }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_group
    @group = current_user.group
    @group_categories = current_user.group_categories
    @activity =  @group.activity
  end

  def set_group_item
    @group_item = GroupItem.find(params[:id])
  end
end
