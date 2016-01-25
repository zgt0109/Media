class Biz::GroupsController < Biz::GroupBaseController
  skip_before_filter :require_group, only: [:index]

  before_filter :set_group, except: [:items, :orders]

  def index
  end

  def categories
  end

  def items
    @group_items_search = @group.group_items.includes(:group_category).on_sale.latest.search(params[:search])
    @group_items = @group_items_search.page(params[:page])
  end

  def orders
    @group_orders_search = current_site.group_orders.latest.search(params[:search])
    @group_orders = @group_orders_search.includes(:group_item).where("group_items.group_type is null or group_items.group_type = 1").page(params[:order_page])

    respond_to do |format|
      format.html
      format.xls {
        send_data(GroupOrder.export_excel(@group_orders_search.page(params[:page_exl]).per(EXPORTING_COUNT)),
        :type => "text/excel;charset=utf-8; header=present", 
        :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
      }
    end
  end

  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to groups_path(anchor: "tab-1"), notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @group.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  private

  def set_group
    @group = current_site.group
    @group = current_site.create_group unless @group
    @activity =  @group.activity
  end
end
