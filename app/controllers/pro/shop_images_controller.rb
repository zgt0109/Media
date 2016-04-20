class Pro::ShopImagesController < Pro::ShopBaseController
  # GET /shop_images
  # GET /shop_images.json
  def index
    @shop_branch = current_site.shop_branches.find(params[:shop_branch_id])
    @shop_images = @shop_branch.shop_images

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shop_images }
    end
  end

  # GET /shop_images/1
  # GET /shop_images/1.json
  def show
    @shop_image = ShopImage.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @shop_image }
    end
  end

  # GET /shop_images/new
  # GET /shop_images/new.json
  def new
    @shop_image = ShopImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shop_image }
    end
  end

  # GET /shop_images/1/edit
  def edit
    @shop_image = ShopImage.find(params[:id])
  end

  # POST /shop_images
  # POST /shop_images.json
  def create
    @shop_image = ShopImage.create(params[:shop_image])
    # @shop_image = ShopImage.new(params[:shop_image])
    #
    # respond_to do |format|
    #   if @shop_image.save
    #     format.html { redirect_to @shop_image, notice: 'Shop image was successfully created.' }
    #     format.json { render json: @shop_image, status: :created, location: @shop_image }
    #   else
    #     format.html { render action: "new" }
    #     format.json { render json: @shop_image.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PUT /shop_images/1
  # PUT /shop_images/1.json
  def update
    @shop_image = ShopImage.find(params[:id])

    respond_to do |format|
      if @shop_image.update_attributes(params[:shop_image])
        format.html { redirect_to @shop_image, notice: 'Shop image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shop_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shop_images/1
  # DELETE /shop_images/1.json
  def destroy
    @shop_image = ShopImage.find(params[:id])
    @shop_image.destroy

    respond_to do |format|
      format.html { redirect_to shop_images_url }
      format.json { head :no_content }
    end
  end
end
