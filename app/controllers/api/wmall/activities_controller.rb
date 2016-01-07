class Api::Wmall::ActivitiesController < Api::Wmall::BaseController
  # GET /api/wmall/activities
  # GET /api/wmall/activities.json
  def index
    #@common_activities = current_mall.activities.tagged_with("common",on: :categories).last(4)
    #@banner_activities = current_mall.activities.tagged_with("banner",on: :categories).last
    @activities = current_mall.activities.tagged_with(["common","banner"],on: :categories, any: true).tagged_with("recommended", on: :statuses)
  end

  def list
    @activities = current_mall.activities
  end
  # GET /api/wmall/activities/1
  # GET /api/wmall/activities/1.json
  def show
    @api_wmall_activity = Wmall::Activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_activity }
    end
  end

  # GET /api/wmall/activities/new
  # GET /api/wmall/activities/new.json
  def new
    @api_wmall_activity = Wmall::Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_activity }
    end
  end

  # GET /api/wmall/activities/1/edit
  def edit
    @api_wmall_activity = Wmall::Activity.find(params[:id])
  end

  # POST /api/wmall/activities
  # POST /api/wmall/activities.json
  def create
    @api_wmall_activity = Wmall::Activity.new(params[:api_wmall_activity])

    respond_to do |format|
      if @api_wmall_activity.save
        format.html { redirect_to @api_wmall_activity, notice: 'Activity was successfully created.' }
        format.json { render json: @api_wmall_activity, status: :created, location: @api_wmall_activity }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/activities/1
  # PUT /api/wmall/activities/1.json
  def update
    @api_wmall_activity = Wmall::Activity.find(params[:id])

    respond_to do |format|
      if @api_wmall_activity.update_attributes(params[:api_wmall_activity])
        format.html { redirect_to @api_wmall_activity, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/activities/1
  # DELETE /api/wmall/activities/1.json
  def destroy
    @api_wmall_activity = Wmall::Activity.find(params[:id])
    @api_wmall_activity.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_activities_url }
      format.json { head :no_content }
    end
  end
end
