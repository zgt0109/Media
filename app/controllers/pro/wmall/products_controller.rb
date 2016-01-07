class Pro::Wmall::ProductsController < Pro::Wmall::BaseController
  # GET /pro/wmall/products
  # GET /pro/wmall/products.json
  def index
    @products = current_mall.products
  end

  # GET /pro/wmall/products/1
  # GET /pro/wmall/products/1.json
  def show
    @pro_wmall_product = Wmall::Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pro_wmall_product }
    end
  end

  # GET /pro/wmall/products/new
  # GET /pro/wmall/products/new.json
  def new
    @pro_wmall_product = Wmall::Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pro_wmall_product }
    end
  end

  # GET /pro/wmall/products/1/edit
  def edit
    @pro_wmall_product = Wmall::Product.find(params[:id])
  end

  # POST /pro/wmall/products
  # POST /pro/wmall/products.json
  def create
    @pro_wmall_product = Wmall::Product.new(params[:pro_wmall_product])

    respond_to do |format|
      if @pro_wmall_product.save
        format.html { redirect_to @pro_wmall_product, notice: 'Product was successfully created.' }
        format.json { render json: @pro_wmall_product, status: :created, location: @pro_wmall_product }
      else
        format.html { render action: "new" }
        format.json { render json: @pro_wmall_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pro/wmall/products/1
  # PUT /pro/wmall/products/1.json
  def update
    @pro_wmall_product = Wmall::Product.find(params[:id])

    respond_to do |format|
      if @pro_wmall_product.update_attributes(params[:pro_wmall_product])
        format.html { redirect_to @pro_wmall_product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pro_wmall_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pro/wmall/products/1
  # DELETE /pro/wmall/products/1.json
  def destroy
    @pro_wmall_product = Wmall::Product.find(params[:id])
    @pro_wmall_product.destroy

    respond_to do |format|
      format.html { redirect_to pro_wmall_products_url }
      format.json { head :no_content }
    end
  end
end
