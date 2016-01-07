class Api::Wmall::ShopAccountsController < ApplicationController
  # GET /api/wmall/shop_accounts
  # GET /api/wmall/shop_accounts.json
  def index
    @api_wmall_shop_accounts = Wmall::ShopAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @api_wmall_shop_accounts }
    end
  end

  # GET /api/wmall/shop_accounts/1
  # GET /api/wmall/shop_accounts/1.json
  def show
    @api_wmall_shop_account = Wmall::ShopAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @api_wmall_shop_account }
    end
  end

  # GET /api/wmall/shop_accounts/new
  # GET /api/wmall/shop_accounts/new.json
  def new
    @api_wmall_shop_account = Wmall::ShopAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @api_wmall_shop_account }
    end
  end

  # GET /api/wmall/shop_accounts/1/edit
  def edit
    @api_wmall_shop_account = Wmall::ShopAccount.find(params[:id])
  end

  # POST /api/wmall/shop_accounts
  # POST /api/wmall/shop_accounts.json
  def create
    @api_wmall_shop_account = Wmall::ShopAccount.new(params[:api_wmall_shop_account])

    respond_to do |format|
      if @api_wmall_shop_account.save
        format.html { redirect_to @api_wmall_shop_account, notice: 'Shop account was successfully created.' }
        format.json { render json: @api_wmall_shop_account, status: :created, location: @api_wmall_shop_account }
      else
        format.html { render action: "new" }
        format.json { render json: @api_wmall_shop_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /api/wmall/shop_accounts/1
  # PUT /api/wmall/shop_accounts/1.json
  def update
    @api_wmall_shop_account = Wmall::ShopAccount.find(params[:id])

    respond_to do |format|
      if @api_wmall_shop_account.update_attributes(params[:api_wmall_shop_account])
        format.html { redirect_to @api_wmall_shop_account, notice: 'Shop account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @api_wmall_shop_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/shop_accounts/1
  # DELETE /api/wmall/shop_accounts/1.json
  def destroy
    @api_wmall_shop_account = Wmall::ShopAccount.find(params[:id])
    @api_wmall_shop_account.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_shop_accounts_url }
      format.json { head :no_content }
    end
  end
end
