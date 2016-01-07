class Pro::EcSellerCatsController < Pro::EcBaseController

  layout "application_gm"

  skip_before_filter :require_ec_shop, :require_commerce_industry, only: [:show]

  before_filter :set_ec_shop#, only: [:index, :new]
  before_filter :set_ec_seller_cat, only: [:show, :edit, :update, :destroy, :update_sorts]
  before_filter :set_ec_seller_cats

  # GET /ec_seller_cats
  # GET /ec_seller_cats.json
  def index

  end

  # GET /ec_seller_cats/1
  # GET /ec_seller_cats/1.json
  def show

  end

  # GET /ec_seller_cats/new
  # GET /ec_seller_cats/new.json
  def new
    @ec_seller_cat = @ec_shop.categories.new(parent_cid: params[:parent_cid].to_i, parent_id: params[:parent_id].to_i)
  end

  # GET /ec_seller_cats/1/edit
  def edit

  end

  def sync_taobao
    authentication_id = current_user.api_user.try(:id)
    if authentication_id
      TaobaoCatsPuller.create(authentication_id)
      redirect_to ec_seller_cats_url, notice: "保存成功"
    else
      redirect_to ec_seller_cats_url, notice: "保存失败"
    end
  end

  # POST /ec_seller_cats
  # POST /ec_seller_cats.json
  def create
    @ec_seller_cat = EcSellerCat.new(params[:ec_seller_cat])
    respond_to do |format|
      if @ec_seller_cat.save
        format.html {redirect_to ec_seller_cats_path, notice: "添加成功"}
        format.json {head :no_content}
      else
        format.json { render json: @ec_seller_cat.errors, status: :unprocessable_entity}
        set_ec_seller_cats
        format.html { render_with_alert 'new', '添加失败'}
      end
    end
  end

  # PUT /ec_seller_cats/1
  # PUT /ec_seller_cats/1.json
  def update
    respond_to do |format|
      if @ec_seller_cat.update_attributes(params[:ec_seller_cat])
        format.html {redirect_to ec_seller_cats_path, notice: "更新成功"}
        format.json {head :no_content}
      else
        format.json { render json: @ec_seller_cat.errors, status: :unprocessable_entity}
        set_ec_seller_cats
        format.html { render_with_alert 'new', '更新失败'}
      end
    end
  end

  # DELETE /ec_seller_cats/1
  # DELETE /ec_seller_cats/1.json
  def destroy
    #if @ec_seller_cat.ec_items.count > 0
    #  redirect_to :back,  notice: "菜单下面有商品， 不能删除"
    #elsif @ec_seller_cat.has_children?
    #  redirect_to :back,  notice: "菜单下面有子菜单， 不能删除"
    #else
    #  if @ec_seller_cat.destroy
    #    redirect_to ec_seller_cats_path, notice: '删除成功'
    #  else
    #    redirect_to :back, notice: '删除失败'
    #  end
    #end
    @ec_seller_cat.delete!
    redirect_to ec_seller_cats_path, notice: '删除成功'
  end


  def update_sorts
    #1:置顶， -1:置底
    if @ec_seller_cat.parent
      @ec_seller_cats = @ec_seller_cat.parent.children.normal.order(:sort_order)
    else
      @ec_seller_cats = @ec_shop.categories.normal.root.order(:sort_order)
    end

    index = @ec_seller_cats.to_a.index(@ec_seller_cat)
    @ec_seller_cats.each_with_index{|category, index| category.sort_order = index + 1}

    if params[:type] == "up"

      unless index -1 >= 0
        render :text => 1
        return
      end

      current_sort = @ec_seller_cats[index].sort_order
      up_sort = @ec_seller_cats[index -1].sort_order

      @ec_seller_cats[index].sort_order = current_sort - 1
      @ec_seller_cats[index -1].sort_order = up_sort + 1
    else
      unless @ec_seller_cats[index + 1]
        render :text => -1
        return
      end

      current_sort = @ec_seller_cats[index].sort_order
      down_sort = @ec_seller_cats[index + 1].sort_order

      @ec_seller_cats[index].sort_order = current_sort + 1
      @ec_seller_cats[index + 1].sort_order = down_sort - 1
    end
    @ec_seller_cats.each do |category|
      category.update_column('sort_order', category.sort_order)
    end
    render :partial=> "sub_menu", :collection => @ec_seller_cats.sort{|x, y| x.sort_order <=> y.sort_order}, :as =>:sub_menu

  end

  private
  def set_ec_seller_cat
    @ec_seller_cat = EcSellerCat.find(params[:id])
  end

  def set_ec_shop
    @ec_shop = current_user.ec_shop
  end

  def set_ec_seller_cats
    @ec_seller_cats = @ec_shop.categories.normal#.unscoped.order(:parent_cid).page(params[:page])
  end
end
