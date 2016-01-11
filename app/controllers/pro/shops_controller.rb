# -*- coding: utf-8 -*-
class Pro::ShopsController < Pro::ShopBaseController
  skip_before_filter :require_industry, only: [:pos]

  def index
    @wx_mp_user = current_user.wx_mp_user
    if params[:activity_type_id].to_s == "6" || params[:activity_type_id].to_s == "7" || session[:current_industry_id] == 10001
      @shop = @wx_mp_user.shop || current_user.create_shop(wx_mp_user_id: current_user.wx_mp_user.id, name: '微店')
      @shop.shop_type = Shop::BOOK_DINNER
      @wx_mp_user.create_activity_for_shop(ActivityType::BOOK_DINNER, { activityable_id: @shop.id, activityable_type: 'Shop'})
      @wx_mp_user.create_activity_for_shop(ActivityType::BOOK_TABLE, { activityable_id: @shop.id, activityable_type: 'Shop'})
    elsif params[:activity_type_id].to_s == "9" || session[:current_industry_id] == 10002
      @shop = @wx_mp_user.shop || current_user.create_shop(wx_mp_user_id: current_user.wx_mp_user.id, name: '微店')
      @shop.shop_type = Shop::TAKE_OUT
      @wx_mp_user.create_activity_for_shop(ActivityType::TAKE_OUT, { activityable_id: @shop.id, activityable_type: 'Shop'})
    else
      return redirect_to four_o_four_url
    end

    if params[:activity_type_id]
      @activity = current_site.activities.where(activity_type_id: params[:activity_type_id]).first
    end
  end

  def create
    @shop = Shop.new(params[:shop])

    respond_to do |format|
      if @shop.save
        format.html { redirect_to :back, notice: '添加成功' }
        format.json { render json: @shop, status: :created, location: @shop }
      else
        format.html { redirect_to :back, alert: '添加失败' }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @shop = Shop.find(params[:id])

    respond_to do |format|
      if @shop.update_attributes(params[:shop])
        format.html { redirect_to :back, notice: '更新成功' }
        format.json { render json: @shop, status: :created, location: @shop }
      else
        format.html { redirect_to :back, alert: '更新失败' }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  def pos
    @shop_branches = current_site.shop_branches.used
  end

end
