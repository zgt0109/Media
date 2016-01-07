class Pro::Wmall::SlidePicturesController < ApplicationController
  # GET /pro/wmall/slide_pictures
  # GET /pro/wmall/slide_pictures.json
  def index
    @pro_wmall_slide_pictures = Wmall::SlidePicture.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pro_wmall_slide_pictures }
    end
  end

  # GET /pro/wmall/slide_pictures/1
  # GET /pro/wmall/slide_pictures/1.json
  def show
    @pro_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pro_wmall_slide_picture }
    end
  end

  # GET /pro/wmall/slide_pictures/new
  # GET /pro/wmall/slide_pictures/new.json
  def new
    @pro_wmall_slide_picture = Wmall::SlidePicture.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pro_wmall_slide_picture }
    end
  end

  # GET /pro/wmall/slide_pictures/1/edit
  def edit
    @pro_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])
  end

  # POST /pro/wmall/slide_pictures
  # POST /pro/wmall/slide_pictures.json
  def create
    @pro_wmall_slide_picture = Wmall::SlidePicture.new(params[:pro_wmall_slide_picture])

    respond_to do |format|
      if @pro_wmall_slide_picture.save
        format.html { redirect_to @pro_wmall_slide_picture, notice: 'Slide picture was successfully created.' }
        format.json { render json: @pro_wmall_slide_picture, status: :created, location: @pro_wmall_slide_picture }
      else
        format.html { render action: "new" }
        format.json { render json: @pro_wmall_slide_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pro/wmall/slide_pictures/1
  # PUT /pro/wmall/slide_pictures/1.json
  def update
    @pro_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])

    respond_to do |format|
      if @pro_wmall_slide_picture.update_attributes(params[:pro_wmall_slide_picture])
        format.html { redirect_to @pro_wmall_slide_picture, notice: 'Slide picture was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pro_wmall_slide_picture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pro/wmall/slide_pictures/1
  # DELETE /pro/wmall/slide_pictures/1.json
  def destroy
    @pro_wmall_slide_picture = Wmall::SlidePicture.find(params[:id])
    @pro_wmall_slide_picture.destroy

    respond_to do |format|
      format.html { redirect_to pro_wmall_slide_pictures_url }
      format.json { head :no_content }
    end
  end
end
