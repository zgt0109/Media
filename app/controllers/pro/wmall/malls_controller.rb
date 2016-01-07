class Pro::Wmall::MallsController < Pro::Wmall::BaseController
  # GET /pro/wmall/malls
  # GET /pro/wmall/malls.json
  def index
    @mall = current_mall
  end

  # GET /pro/wmall/malls/1
  # GET /pro/wmall/malls/1.json
  def show
    @mall = Pro::Wmall::Mall.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mall }
    end
  end

  # GET /pro/wmall/malls/new
  # GET /pro/wmall/malls/new.json
  def new
    @mall = Pro::Wmall::Mall.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mall }
    end
  end

  # GET /pro/wmall/malls/1/edit
  def edit
    @mall = Pro::Wmall::Mall.find(params[:id])
  end

  # POST /pro/wmall/malls
  # POST /pro/wmall/malls.json
  def create
    @mall = Pro::Wmall::Mall.new(params[:mall])

    respond_to do |format|
      if @mall.save
        format.html { redirect_to @mall, notice: 'Mall was successfully created.' }
        format.json { render json: @mall, status: :created, location: @mall }
      else
        format.html { render action: "new" }
        format.json { render json: @mall.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pro/wmall/malls/1
  # PUT /pro/wmall/malls/1.json
  def update
    @mall = Pro::Wmall::Mall.find(params[:id])

    respond_to do |format|
      if @mall.update_attributes(params[:mall])
        format.html { redirect_to @mall, notice: 'Mall was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mall.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pro/wmall/malls/1
  # DELETE /pro/wmall/malls/1.json
  def destroy
    @mall = Pro::Wmall::Mall.find(params[:id])
    @mall.destroy

    respond_to do |format|
      format.html { redirect_to malls_url }
      format.json { head :no_content }
    end
  end
end
