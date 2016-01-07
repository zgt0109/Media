class Api::Wmall::ProductsController < Api::Wmall::BaseController
  # GET /api/wmall/products
  # GET /api/wmall/products.json
  def index
    @products = current_mall.products.tagged_with("recommended", on: :statuses)
  end

  def categories
    @categories = current_mall.products.category_counts
  end

  def shop
    @shop = current_mall.shops.find params[:shop_id]
    @products = @shop.products
  end

  def list
    category_name = params[:category] || '全部'
    @products = case category_name
    when '全部'
      current_mall.products
    else
      current_mall.products.tagged_with(category_name, on: :categories)
    end
  end

  # GET /api/wmall/products/1
  # GET /api/wmall/products/1.json
  def show
    @product = current_mall.products.find(params[:id])
  end

  # GET /api/wmall/products/new
  # GET /api/wmall/products/new.json
  def new
    @api_wmall_product = Wmall::Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_product }
    end
  end

  # GET /api/wmall/products/1/edit
  def edit
    @api_wmall_product = Wmall::Product.find(params[:id])
  end

  # POST /api/wmall/products
  # POST /api/wmall/products.json
  def create
    @api_wmall_product = Wmall::Product.new(params[:api_wmall_product])

    respond_to do |format|
      if @api_wmall_product.save
        format.html { redirect_to @api_wmall_product, notice: 'Product was successfully created.' }
        format.json { render json: @api_wmall_product, status: :created, location: @api_wmall_product }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/products/1
  # PUT /api/wmall/products/1.json
  def update
    @api_wmall_product = Wmall::Product.find(params[:id])

    respond_to do |format|
      if @api_wmall_product.update_attributes(params[:api_wmall_product])
        format.html { redirect_to @api_wmall_product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/products/1
  # DELETE /api/wmall/products/1.json
  def destroy
    @api_wmall_product = Wmall::Product.find(params[:id])
    @api_wmall_product.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_products_url }
      format.json { head :no_content }
    end
  end
end
