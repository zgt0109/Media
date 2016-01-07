class Api::Wmall::ShopActivitiesController < Api::Wmall::BaseController
  # GET /api/wmall/shop_activities
  # GET /api/wmall/shop_activities.json
  before_filter :set_shop

  def index
    @activities = @shop.activities
  end

  # GET /api/wmall/shop_activities/1
  # GET /api/wmall/shop_activities/1.json
  def show
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_shop_activity }
    end
  end

  # GET /api/wmall/shop_activities/new
  # GET /api/wmall/shop_activities/new.json
  def new
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_shop_activity }
    end
  end

  # GET /api/wmall/shop_activities/1/edit
  def edit
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.find(params[:id])
  end

  # POST /api/wmall/shop_activities
  # POST /api/wmall/shop_activities.json
  def create
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.new(params[:api_wmall_shop_activity])

    respond_to do |format|
      if @api_wmall_shop_activity.save
        format.html { redirect_to @api_wmall_shop_activity, notice: 'Shop activity was successfully created.' }
        format.json { render json: @api_wmall_shop_activity, status: :created, location: @api_wmall_shop_activity }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_shop_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/shop_activities/1
  # PUT /api/wmall/shop_activities/1.json
  def update
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.find(params[:id])

    respond_to do |format|
      if @api_wmall_shop_activity.update_attributes(params[:api_wmall_shop_activity])
        format.html { redirect_to @api_wmall_shop_activity, notice: 'Shop activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_shop_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/shop_activities/1
  # DELETE /api/wmall/shop_activities/1.json
  def destroy
    @api_wmall_shop_activity = Api::Wmall::ShopActivity.find(params[:id])
    @api_wmall_shop_activity.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_shop_activities_url }
      format.json { head :no_content }
    end
  end
end
