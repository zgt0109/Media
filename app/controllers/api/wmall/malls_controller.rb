class Api::Wmall::MallsController < Api::Wmall::BaseController
  def wx_user
  end

  def following_shops
  end

  # GET /api/wmall/malls
  # GET /api/wmall/malls.json
  def index
    @api_wmall_malls = Api::Wmall::Mall.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @api_wmall_malls }
    end
  end

  # GET /api/wmall/malls/1
  # GET /api/wmall/malls/1.json
  def show
    @api_wmall_mall = Api::Wmall::Mall.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_mall }
    end
  end

  # GET /api/wmall/malls/new
  # GET /api/wmall/malls/new.json
  def new
    @api_wmall_mall = Api::Wmall::Mall.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_mall }
    end
  end

  # GET /api/wmall/malls/1/edit
  def edit
    @api_wmall_mall = Api::Wmall::Mall.find(params[:id])
  end

  # POST /api/wmall/malls
  # POST /api/wmall/malls.json
  def create
    @api_wmall_mall = Api::Wmall::Mall.new(params[:api_wmall_mall])

    respond_to do |format|
      if @api_wmall_mall.save
        format.html { redirect_to @api_wmall_mall, notice: 'Mall was successfully created.' }
        format.json { render json: @api_wmall_mall, status: :created, location: @api_wmall_mall }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_mall.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/malls/1
  # PUT /api/wmall/malls/1.json
  def update
    @api_wmall_mall = Api::Wmall::Mall.find(params[:id])

    respond_to do |format|
      if @api_wmall_mall.update_attributes(params[:api_wmall_mall])
        format.html { redirect_to @api_wmall_mall, notice: 'Mall was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_mall.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/malls/1
  # DELETE /api/wmall/malls/1.json
  def destroy
    @api_wmall_mall = Api::Wmall::Mall.find(params[:id])
    @api_wmall_mall.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_malls_url }
      format.json { head :no_content }
    end
  end
end
