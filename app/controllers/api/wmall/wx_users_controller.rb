class Api::Wmall::WxUsersController < Api::Wmall::BaseController
  # GET /api/wmall/wx_users
  # GET /api/wmall/wx_users.json
  def index
    @api_wmall_wx_users = Api::Wmall::WxUser.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @api_wmall_wx_users }
    end
  end

  # GET /api/wmall/wx_users/1
  # GET /api/wmall/wx_users/1.json
  def show
    @wx_user = WxUser.find params[:id]
    @usable_points = VipUser.where(wx_user_id: @wx_user.id, supplier_id: current_user.id).first.try(:usable_points).to_i
  end

  def following_shops
    @wx_user = WxUser.find params[:id]
    @shops = @wx_user.following_by_type("Wmall::Shop").where(mall_id: current_mall.id)
  end

  # GET /api/wmall/wx_users/new
  # GET /api/wmall/wx_users/new.json
  def new
    @api_wmall_wx_user = Api::Wmall::WxUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_wx_user }
    end
  end

  # GET /api/wmall/wx_users/1/edit
  def edit
    @api_wmall_wx_user = Api::Wmall::WxUser.find(params[:id])
  end

  # POST /api/wmall/wx_users
  # POST /api/wmall/wx_users.json
  def create
    @api_wmall_wx_user = Api::Wmall::WxUser.new(params[:api_wmall_wx_user])

    respond_to do |format|
      if @api_wmall_wx_user.save
        format.html { redirect_to @api_wmall_wx_user, notice: 'Wx user was successfully created.' }
        format.json { render json: @api_wmall_wx_user, status: :created, location: @api_wmall_wx_user }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_wx_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/wx_users/1
  # PUT /api/wmall/wx_users/1.json
  def update
    @api_wmall_wx_user = Api::Wmall::WxUser.find(params[:id])

    respond_to do |format|
      if @api_wmall_wx_user.update_attributes(params[:api_wmall_wx_user])
        format.html { redirect_to @api_wmall_wx_user, notice: 'Wx user was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_wx_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/wx_users/1
  # DELETE /api/wmall/wx_users/1.json
  def destroy
    @api_wmall_wx_user = Api::Wmall::WxUser.find(params[:id])
    @api_wmall_wx_user.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_wx_users_url }
      format.json { head :no_content }
    end
  end
end
