class Pro::Wmall::ShopAccountsController < ApplicationController
  # GET /pro/wmall/shop_accounts
  # GET /pro/wmall/shop_accounts.json
  def index
    @pro_wmall_shop_accounts = Wmall::ShopAccount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pro_wmall_shop_accounts }
    end
  end

  # GET /pro/wmall/shop_accounts/1
  # GET /pro/wmall/shop_accounts/1.json
  def show
    @pro_wmall_shop_account = Wmall::ShopAccount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pro_wmall_shop_account }
    end
  end

  # GET /pro/wmall/shop_accounts/new
  # GET /pro/wmall/shop_accounts/new.json
  def new
    @pro_wmall_shop_account = Wmall::ShopAccount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pro_wmall_shop_account }
    end
  end

  # GET /pro/wmall/shop_accounts/1/edit
  def edit
    @pro_wmall_shop_account = Wmall::ShopAccount.find(params[:id])
  end

  # POST /pro/wmall/shop_accounts
  # POST /pro/wmall/shop_accounts.json
  def create
    @pro_wmall_shop_account = Wmall::ShopAccount.new(params[:pro_wmall_shop_account])

    respond_to do |format|
      if @pro_wmall_shop_account.save
        format.html { redirect_to @pro_wmall_shop_account, notice: 'Shop account was successfully created.' }
        format.json { render json: @pro_wmall_shop_account, status: :created, location: @pro_wmall_shop_account }
      else
        format.html { render action: "new" }
        format.json { render json: @pro_wmall_shop_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pro/wmall/shop_accounts/1
  # PUT /pro/wmall/shop_accounts/1.json
  def update
    @pro_wmall_shop_account = Wmall::ShopAccount.find(params[:id])

    respond_to do |format|
      if @pro_wmall_shop_account.update_attributes(params[:pro_wmall_shop_account])
        format.html { redirect_to @pro_wmall_shop_account, notice: 'Shop account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pro_wmall_shop_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pro/wmall/shop_accounts/1
  # DELETE /pro/wmall/shop_accounts/1.json
  def destroy
    @pro_wmall_shop_account = Wmall::ShopAccount.find(params[:id])
    @pro_wmall_shop_account.destroy

    respond_to do |format|
      format.html { redirect_to pro_wmall_shop_accounts_url }
      format.json { head :no_content }
    end
  end
end
