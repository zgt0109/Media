class Api::Wmall::SlidePicturesController < Api::Wmall::BaseController
  # GET /api/wmall/slide_pictures
  # GET /api/wmall/slide_pictures.json
  def index
    @slide_pictures = current_mall.slide_pictures
  end

  # GET /api/wmall/slide_pictures/1
  # GET /api/wmall/slide_pictures/1.json
  def show
    @api_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_slide_picture }
    end
  end

  # GET /api/wmall/slide_pictures/new
  # GET /api/wmall/slide_pictures/new.json
  def new
    @api_wmall_slide_picture = Wmall::SlidePicture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_slide_picture }
    end
  end

  # GET /api/wmall/slide_pictures/1/edit
  def edit
    @api_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])
  end

  # POST /api/wmall/slide_pictures
  # POST /api/wmall/slide_pictures.json
  def create
    @api_wmall_slide_picture = Wmall::SlidePicture.new(params[:api_wmall_slide_picture])

    respond_to do |format|
      if @api_wmall_slide_picture.save
        format.html { redirect_to @api_wmall_slide_picture, notice: 'Slide picture was successfully created.' }
        format.json { render json: @api_wmall_slide_picture, status: :created, location: @api_wmall_slide_picture }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_slide_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/slide_pictures/1
  # PUT /api/wmall/slide_pictures/1.json
  def update
    @api_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])

    respond_to do |format|
      if @api_wmall_slide_picture.update_attributes(params[:api_wmall_slide_picture])
        format.html { redirect_to @api_wmall_slide_picture, notice: 'Slide picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_slide_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/slide_pictures/1
  # DELETE /api/wmall/slide_pictures/1.json
  def destroy
    @api_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])
    @api_wmall_slide_picture.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_slide_pictures_url }
      format.json { head :no_content }
    end
  end
end
