class Pro::EcShopsController < Pro::EcBaseController
  skip_before_filter :require_ec_shop, only: [:index]
  before_filter :set_ec_shop
  layout "application_gm"

  def index

  end
  
  def alipay
    if request.put?
      current_user.update_attributes(params[:supplier])
      redirect_to :back, notice: '更新成功'
    end
  end

  def show
    @ec_shop = EcShop.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @ec_shop }
    end
  end

  # GET /ec_shops/new
  # GET /ec_shops/new.json
  def new
    @ec_shop = EcShop.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ec_shop }
    end
  end

  # GET /ec_shops/1/edit
  def edit
    @ec_shop = EcShop.find(params[:id])
  end

  # POST /ec_shops
  # POST /ec_shops.json
  def create

    @ec_shop = EcShop.new(params[:ec_shop])

    respond_to do |format|
      if @ec_shop.save
        format.html { redirect_to @ec_shop, notice: 'Ec shop was successfully created.' }
        format.json { render json: @ec_shop, status: :created, location: @ec_shop }
      else
        format.html { render action: "new" }
        format.json { render json: @ec_shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ec_shops/1
  # PUT /ec_shops/1.json
  def update
    respond_to do |format|
      if @ec_shop.update_attributes(params[:ec_shop])
        format.html { redirect_to :back, notice: '保存成功' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_cover_pic
    @ec_shop.cover_pic.remove!
    if @ec_shop.save
      redirect_to :back
    else
      redirect_to :back, :notice => "操作失败"
    end
  end

  # DELETE /ec_shops/1
  # DELETE /ec_shops/1.json
  def destroy
    if @ec_shop.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end


  def  set_ec_shop
    @ec_shop = current_user.ec_shop
    @ec_shop = current_user.wx_mp_user.create_shop unless @ec_shop
  end



end
