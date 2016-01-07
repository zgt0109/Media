class Pro::Wmall::ActivitiesController < Pro::Wmall::BaseController
  # GET /pro/wmall/activities
  # GET /pro/wmall/activities.json
  def index
    @activities = current_mall.activities
  end

  # GET /pro/wmall/activities/1
  # GET /pro/wmall/activities/1.json
  def show
    @pro_wmall_activity = Wmall::Activity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pro_wmall_activity }
    end
  end

  # GET /pro/wmall/activities/new
  # GET /pro/wmall/activities/new.json
  def new
    @pro_wmall_activity = Wmall::Activity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pro_wmall_activity }
    end
  end

  # GET /pro/wmall/activities/1/edit
  def edit
    @pro_wmall_activity = Wmall::Activity.find(params[:id])
  end

  # POST /pro/wmall/activities
  # POST /pro/wmall/activities.json
  def create
    @pro_wmall_activity = Wmall::Activity.new(params[:pro_wmall_activity])

    respond_to do |format|
      if @pro_wmall_activity.save
        format.html { redirect_to @pro_wmall_activity, notice: 'Activity was successfully created.' }
        format.json { render json: @pro_wmall_activity, status: :created, location: @pro_wmall_activity }
      else
        format.html { render action: "new" }
        format.json { render json: @pro_wmall_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pro/wmall/activities/1
  # PUT /pro/wmall/activities/1.json
  def update
    @pro_wmall_activity = Wmall::Activity.find(params[:id])

    respond_to do |format|
      if @pro_wmall_activity.update_attributes(params[:pro_wmall_activity])
        format.html { redirect_to @pro_wmall_activity, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pro_wmall_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pro/wmall/activities/1
  # DELETE /pro/wmall/activities/1.json
  def destroy
    @pro_wmall_activity = Wmall::Activity.find(params[:id])
    @pro_wmall_activity.destroy

    respond_to do |format|
      format.html { redirect_to pro_wmall_activities_url }
      format.json { head :no_content }
    end
  end
end
