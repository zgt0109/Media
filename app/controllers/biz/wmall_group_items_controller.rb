class Biz::WmallGroupItemsController < Biz::WmallGroupBaseController

  before_filter :set_group
  before_filter :find_group_item, only: [:edit, :update, :destroy, :recommend_switch]
  before_filter :belongs_to_shops, only:[:create, :new, :edit]

  def index
    conn = GroupItem.get_conditions params
    @wmall_group_items = @group.group_items.includes(:shop).wmall.latest.where(conn)
    if params[:auth_token].present?
      @wmall_group_items = @wmall_group_items.seller_items.selling.latest  
    else
      @wmall_group_items = @wmall_group_items.page(params[:item_page]) 
    end  

    #@group_orders_search = current_user.group_orders.latest.search(params[:search])
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
    @current_titles << '商品管理'
    @group_item = @group.group_items.wmall.new
  end

  def create
    @shop = current_user.try(:mall).try(:shops).where(id: params[:shop_id]).first
    return redirect_to :back, notice: "无效的商家" unless @shop
    @group_item = @shop.group_items.build(wx_mp_user_id: @group.wx_mp_user_id, group_category_id: 0, group_type: 2, supplier_id: current_user.id, group_id: @group.id)
    @group_item.attributes = params[:group_item]
    if @group_item.save
      redirect_to wmall_group_items_path, notice: "添加成功"
    else
      render action: :new
    end
  end

  def recommend_switch
    tag = @group_item.recommend?
    if current_user.group_items.tagged_with('recommend', on: :recommends).count < 3
      tag ? @group_item.recommend_list.remove('recommend') : @group_item.recommend_list.add('recommend')
      return render js: "$('#item_#{@group_item.id}').html('#{tag ? '': '取消'}推荐')" if @group_item.save
    else
      if tag
        tag ? @group_item.recommend_list.remove('recommend') : @group_item.recommend_list.add('recommend')
        return render js: "$('#item_#{@group_item.id}').html('#{tag ? '': '取消'}推荐')" if @group_item.save
      else
        render js: "showTip('warning','最多只能推荐3个商品')"
      end
    end
  end

  def recommend_list
    @group_items = current_user.group_items.tagged_with('recommend', on: :recommends).limit(3) #||  current_user.group_items.latest.limit(3)
    @group_items =  current_user.group_items.seller_items.selling.latest.limit(3) if @group_items.blank?
  end

  def edit
   # @shops = current_user.try(:mall).try(:shops).map{|s| [s.name,s.id]}
    @shop = [@group_item.try(:groupable).try(:name),@group_item.try(:groupable).try(:id)]
  end

  def update
    params[:group_item][:groupable_id] = params[:shop_id]
    @group_item.attributes = params[:group_item]
    if @group_item.save
      redirect_to wmall_group_items_path, notice: "更新成功"
    else
      render action: :new#, notice: "填写信息不完整"
    end
  end

  def destroy
    respond_to do |format|
      if @group_item.delete!
        msg = @group_item.deleted? ? "下架" : "上架"
        format.html { redirect_to wmall_group_items_path, notice: "#{msg}成功" }
        format.json { head :no_content }
      else
        format.html { redirect_to wmall_group_items_path, notice: "#{msg}失败" }
        format.json { render json: @group_item.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_group
    @group = current_user.group
    @group = current_user.wx_mp_user.create_group unless @group
  end

  def find_group_item
    @group_item ||= @group.group_items.wmall.where(id: params[:id]).first
  end

  def belongs_to_shops
    @shops = current_user.try(:mall).try(:shops).pluck(:name, :id)
  end
end
