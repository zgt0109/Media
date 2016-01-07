class Api::Wmall::ShopPicturesController < Api::Wmall::BaseController
  # GET /api/wmall/shop_pictures
  # GET /api/wmall/shop_pictures.json
  before_filter :set_shop

  def index
    @pictures = @shop.pictures
  end

  # GET /api/wmall/shop_pictures/1
  # GET /api/wmall/shop_pictures/1.json
  def show
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_shop_picture }
    end
  end

  # GET /api/wmall/shop_pictures/new
  # GET /api/wmall/shop_pictures/new.json
  def new
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_shop_picture }
    end
  end

  # GET /api/wmall/shop_pictures/1/edit
  def edit
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.find(params[:id])
  end

  # POST /api/wmall/shop_pictures
  # POST /api/wmall/shop_pictures.json
  def create
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.new(params[:api_wmall_shop_picture])

    respond_to do |format|
      if @api_wmall_shop_picture.save
        format.html { redirect_to @api_wmall_shop_picture, notice: 'Shop picture was successfully created.' }
        format.json { render json: @api_wmall_shop_picture, status: :created, location: @api_wmall_shop_picture }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_shop_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/shop_pictures/1
  # PUT /api/wmall/shop_pictures/1.json
  def update
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.find(params[:id])

    respond_to do |format|
      if @api_wmall_shop_picture.update_attributes(params[:api_wmall_shop_picture])
        format.html { redirect_to @api_wmall_shop_picture, notice: 'Shop picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_shop_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/shop_pictures/1
  # DELETE /api/wmall/shop_pictures/1.json
  def destroy
    @api_wmall_shop_picture = Api::Wmall::ShopPicture.find(params[:id])
    @api_wmall_shop_picture.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_shop_pictures_url }
      format.json { head :no_content }
    end
  end

end
