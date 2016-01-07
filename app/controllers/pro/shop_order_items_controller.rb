class Pro::ShopOrderItemsController < Pro::ShopBaseController
  # GET /shop_order_items
  # GET /shop_order_items.json
  def index
    @shop_order_items = ShopOrderItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shop_order_items }
    end
  end

  # GET /shop_order_items/1
  # GET /shop_order_items/1.json
  def show
    @shop_order_item = ShopOrderItem.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @shop_order_item }
    end
  end

  # GET /shop_order_items/new
  # GET /shop_order_items/new.json
  def new
    @shop_order_item = ShopOrderItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shop_order_item }
    end
  end

  # GET /shop_order_items/1/edit
  def edit
    @shop_order_item = ShopOrderItem.find(params[:id])
  end

  # POST /shop_order_items
  # POST /shop_order_items.json
  def create
    @shop_order_item = ShopOrderItem.new(params[:shop_order_item])

    respond_to do |format|
      if @shop_order_item.save
        format.html { redirect_to @shop_order_item, notice: 'Shop order item was successfully created.' }
        format.json { render json: @shop_order_item, status: :created, location: @shop_order_item }
      else
        format.html { render action: "new" }
        format.json { render json: @shop_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shop_order_items/1
  # PUT /shop_order_items/1.json
  def update
    @shop_order_item = ShopOrderItem.find(params[:id])

    respond_to do |format|
      if @shop_order_item.update_attributes(params[:shop_order_item])
        format.html { redirect_to @shop_order_item, notice: 'Shop order item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shop_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shop_order_items/1
  # DELETE /shop_order_items/1.json
  def destroy
    @shop_order_item = ShopOrderItem.find(params[:id])
    @shop_order_item.destroy

    respond_to do |format|
      format.html { redirect_to :back, notice: '删除成功' }
      format.json { head :no_content }
    end
  end
end
