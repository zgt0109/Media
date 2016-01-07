class Pro::Wmall::ShopsController < Pro::Wmall::BaseController
  # GET /pro/wmall/shops
  # GET /pro/wmall/shops.json
  def index
    @shops = current_mall.shops
  end

  # GET /pro/wmall/shops/1
  # GET /pro/wmall/shops/1.json
  def show
    @shop = Wmall::Shop.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shop }
    end
  end

  # GET /pro/wmall/shops/new
  # GET /pro/wmall/shops/new.json
  def new
    @shop = current_mall.shops.new
  end

  # GET /pro/wmall/shops/1/edit
  def edit
    @shop = Wmall::Shop.find(params[:id])
  end

  # POST /pro/wmall/shops
  # POST /pro/wmall/shops.json
  def create
    @shop = current_mall.shops.new(params[:shop])
    @shop.category_list.add(params[:shop_category])

    if @shop.save
      redirect_to edit_pro_wmall_shop_path(@shop), notice: 'Shop was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /pro/wmall/shops/1
  # PUT /pro/wmall/shops/1.json
  def update
    @shop = current_mall.shops.find(params[:id])
    @shop.category_list = params[:shop_category]

    if @shop.update_attributes(params[:shop])
      redirect_to edit_pro_wmall_shop_path(@shop), notice: 'Shop was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /pro/wmall/shops/1
  # DELETE /pro/wmall/shops/1.json
  def destroy
    @shop = Wmall::Shop.find(params[:id])
    @shop.destroy

    respond_to do |format|
      format.html { redirect_to pro_wmall_shops_url }
      format.json { head :no_content }
    end
  end
end
