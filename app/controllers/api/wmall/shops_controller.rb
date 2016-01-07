class Api::Wmall::ShopsController < Api::Wmall::BaseController
  # GET /api/wmall/shops
  # GET /api/wmall/shops.json
  def index
    @shops = current_mall.shops.tagged_with("recommended", on: :statuses)
  end

  def list
    @categories = current_mall.shops.category_counts
  end

  def all
    @shops = current_mall.shops
  end

  def category
    @category_name = params[:category]
    @shops = current_mall.shops.tagged_with(@category_name, on: :categories)
  end

  # GET /api/wmall/shops/1
  # GET /api/wmall/shops/1.json
  def show
    @shop = current_mall.shops.find(params[:id])
    @activities = @shop.activities
  end

  def follow_switching
    @shop = current_mall.shops.find(params[:id])
    current_wx_user.following?(@shop) ? current_wx_user.stop_following(@shop) : current_wx_user.follow(@shop)
    render json: {code: 0, message: "关注更新成功", follow_status: current_wx_user.following?(@shop)}
  rescue => e
    logger.error "#{e.message}: #{e.backtrace}"
    render json: {code: -1, message: "关注更新失败"}
  end

  def comments
    @shop = current_mall.shops.find(params[:id])
    @comments = @shop.comments.order("created_at desc")
  end

  def comment
    @shop = current_mall.shops.find(params[:id])
    @shop.comments.create params[:comment]
    render json: {code: 0, message: "评论成功"}
  rescue => e
    logger.error "#{e.message}: #{e.backtrace}"
    render json: {code: -1, message: "评论失败"}
  end

  # GET /api/wmall/shops/new
  # GET /api/wmall/shops/new.json
  def new
    @api_wmall_shop = Wmall::Shop.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_shop }
    end
  end

  # GET /api/wmall/shops/1/edit
  def edit
    @api_wmall_shop = Wmall::Shop.find(params[:id])
  end

  # POST /api/wmall/shops
  # POST /api/wmall/shops.json
  def create
    @api_wmall_shop = Wmall::Shop.new(params[:api_wmall_shop])

    respond_to do |format|
      if @api_wmall_shop.save
        format.html { redirect_to @api_wmall_shop, notice: 'Shop was successfully created.' }
        format.json { render json: @api_wmall_shop, status: :created, location: @api_wmall_shop }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/shops/1
  # PUT /api/wmall/shops/1.json
  def update
    @api_wmall_shop = Wmall::Shop.find(params[:id])

    respond_to do |format|
      if @api_wmall_shop.update_attributes(params[:api_wmall_shop])
        format.html { redirect_to @api_wmall_shop, notice: 'Shop was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/shops/1
  # DELETE /api/wmall/shops/1.json
  def destroy
    @api_wmall_shop = Wmall::Shop.find(params[:id])
    @api_wmall_shop.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_shops_url }
      format.json { head :no_content }
    end
  end
end
