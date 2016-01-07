class Pro::EcItemsController < Pro::EcBaseController
  layout "application_gm"
  before_filter :set_ec_shop
  before_filter :set_ec_item, only: [:show, :edit, :update, :destroy]

  # GET /ec_items
  # GET /ec_items.json
  def index
    params[:status] = 1 unless params.keys.include?('status')
    @ec_items = Kaminari.paginate_array(@ec_shop.show_items(params)).page(params[:page])
    @ec_seller_cat_selects = @ec_shop.multilevel_menu params
    3.times{|index| @ec_seller_cat_selects.push([index + 1, []]) unless @ec_seller_cat_selects[index].present?}
  end

  # GET /ec_items/1
  # GET /ec_items/1.json
  def show
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @ec_item }
    end
  end

  # GET /ec_items/new
  # GET /ec_items/new.json
  def new
    @ec_item = EcItem.new
    @ec_item_picture = @ec_item.ec_item_pictures.new
    @ec_seller_cat_selects = @ec_shop.multilevel_menu params
    render layout: 'application_pop'
  end

  # GET /ec_items/1/edit
  def edit
    @ec_seller_cat_selects = @ec_item.multilevel_menu params
    @ec_item_picture = @ec_item.ec_item_pictures.new if @ec_item.ec_item_pictures.count == 0
    render layout: 'application_pop'
  end

  def sync_taobao
    authentication_id = current_user.api_user.try(:id)
    if authentication_id
      TaobaoItemsPuller.create(authentication_id)
      redirect_to ec_items_url, notice: "保存成功"
    else
      redirect_to ec_items_url, notice: "保存失败"
    end
  end

  # POST /ec_items
  # POST /ec_items.json
  def create
    @ec_item = EcItem.new(params[:ec_item])

    if @ec_item.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "添加失败"
      @ec_seller_cat_selects = @ec_shop.multilevel_menu params
      render action: 'new', layout: 'application_pop'
    end

  end

  # PUT /ec_items/1
  # PUT /ec_items/1.json
  def update
    if @ec_item.update_attributes(params[:ec_item])
      flash[:notice] = "保存成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "保存失败"
      @ec_seller_cat_selects = @ec_shop.multilevel_menu params
      render action: 'edit', layout: 'application_pop'
    end

  end

  # DELETE /ec_items/1
  # DELETE /ec_items/1.json
  def destroy
    if @ec_item.delete!
      msg = @ec_item.deleted? ? "下架" : "上架"
      redirect_to :back, notice: "#{msg}成功"
    else
      redirect_to :back, notice: "#{msg}失败"
    end
  end

  def destroy_multi
    if params[:ids].present?
      @ec_shop.ec_items.where(id: params[:ids]).update_all(status: EcItem::DELETED)
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '请先选中需要下架的商品'
    end
  end


  private

  def set_ec_shop
    @ec_shop = current_user.ec_shop
  end

  def set_ec_item
    @ec_item = EcItem.find(params[:id])
  end
end
