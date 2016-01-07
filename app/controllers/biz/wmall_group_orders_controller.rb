class Biz::WmallGroupOrdersController < Biz::WmallGroupBaseController
  before_filter :set_group
  before_filter :set_group_order, only: [:show, :consume, :destroy, :sn_consume]

  def index
    #conn = "and (wmall_shops.id like '%#{params[:mall_name]}%' or wmall_shops.name like '%#{params[:mall_name]}%')"if params[:mall_name].present?
    conn = GroupOrder.get_conditions params
    @group_orders_search = current_user.group_orders.latest.search(params[:search])
    @wmall_group_orders = @group_orders_search.includes(:payments,:group_item =>:shop).where(conn).page(params[:order_page])
    respond_to do |format|
      format.html
      format.json
      format.xls
    end
  end

  def list
    conn = GroupOrder.get_conditions params
    @group_orders_search = current_user.group_orders.latest.consumed.search(params[:search])
    @wmall_group_orders = @group_orders_search.includes(:payments,:group_item => :shop).where(conn).page(params[:order_page])
    respond_to do |format|
      format.html
      format.json
      format.xls
    end
  end

  def bill
    conn = "group_orders.created_at >= '#{params[:start_at]}' and group_orders.created_at <= '#{params[:end_at]}'" if params[:start_at].present? && params[:end_at].present?
    @search = current_user.try(:mall).try(:shops).search(params[:search])
    @shops = @search.joins(:group_items => :group_orders).where(conn).select("wmall_shops.sn, wmall_shops.id, wmall_shops.name, SUM(group_orders.qty) as qty, SUM(group_orders.total_amount) as amount").where("group_orders.status in (2,5,6)").group("wmall_shops.id").page(params[:page])
  end

  def show
    respond_to do |format|
      format.html{render layout: 'application_pop'}
      format.json{render json: @group_order}
    end
  end

  def consume
    if @group_order.consume!
      redirect_to wmall_group_orders_path, notice: '消费成功'
    else
      redirect_to wmall_group_orders_path, notice: '消费失败'
    end
  end

  def destroy
    if @group_order.delete!
      redirect_to wmall_group_orders_path, notice: '取消成功'
    else
      redirect_to wmall_group_orders_path, notice: '取消失败'
    end
  end

  def sn
    @group_order = current_user.group_orders.where(code: params[:code]).first if params[:code].present?
    @group_order = nil if params[:shop_id].present? &&  @group_order.try(:group_item).try(:groupable_id) != params[:shop_id].to_i
    respond_to do |format|
      format.html{render layout: 'application_pop'}
      format.json
    end
  end

  def sn_consume
    respond_to do |format|
      if @group_order.paid? && @group_order.consume!
        flash[:notice] = "核销成功"
        format.html{render inline: "<script>parent.location.reload();</script>"}
        format.json{render json:{errcode: 0, message: "success"}}
      else
        flash[:notice] = "核销失败"
        format.html{render inline: "<script>parent.location.reload();</script>"}
        format.json{render json:{errcode: 1, message: "faild"}}
      end
    end

  end


  private
  def set_group_order
    @group_order = current_user.group_orders.find(params[:id])
    @group_item  = @group_order.group_item
  end

  def set_group
    @group = current_user.group
    @activity =  @group.activity
  end
end
