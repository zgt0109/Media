# -*- coding: utf-8 -*-
class Biz::WebsitePicturesController < ApplicationController
  include WxReplyMessage
  before_filter :set_website
  before_filter :set_website_picture, only: [:show, :edit, :update, :destroy]

  def index
    return redirect_to websites_path, alert: '请先添加微信公共帐号' unless @website
    @pictures = @website.website_pictures
  end

  def new
    if @website.website_pictures.count >= 5
      redirect_to website_pictures_path, notice: '最多支持上传5张图片'
      return
    end
    @picture =  @website.website_pictures.new
    # @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
    @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
    #render layout: 'application_pop'
  end

  def edit
    # if @picture.menuable_type == 'EcSellerCat'
    #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid), category_id: @picture.menuable_id).to_a.slice(0, 2)
    # else
    #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
    # end
    @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
    #render layout: 'application_pop'
  end
  
  def create
    @picture = WebsitePicture.new(params[:website_picture])
    if @picture.save
      redirect_to website_pictures_path, notice: '添加成功'
    else
      flash[:alert] = "添加失败"
      # if @picture.menuable_type == 'EcSellerCat'
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid), category_id: @picture.menuable_id).to_a.slice(0, 2)
      # else
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
      # end
      @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
      render action: 'new'
    end
  end

  def update
    if @picture.update_attributes(params[:website_picture])
      redirect_to website_pictures_path, notice: '更新成功'
    else
      flash[:alert] = "更新失败"
      # if @picture.menuable_type == 'EcSellerCat'
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid), category_id: @picture.menuable_id).to_a.slice(0, 2)
      # else
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @picture.website.try(:site).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
      # end
      @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
      render action: 'edit'#, layout: 'application_pop'
    end
  end

  def destroy
    if @picture.destroy
      redirect_to website_pictures_path, notice: '删除成功'
    else
      redirect_to website_pictures_path, alert: '删除失败'
    end
  end

  def find_activities
    @picture = @website.website_pictures.find(params[:id]) if params[:id].present?
    ids = params[:ids].split(',').to_a.map{|f| f.to_i}

    #微服务中添加ktv预定
    #ids = [29, 48] if ids == [29]

    @activities = current_site.activities.active.unexpired.where(activity_type_id: ids)
    ids.each{|f| @is_exist_activity_time = ActivityType.exist_activity_time.include?(f) }
    render :partial=> "activities"
  end

  private
  
  def set_website
    @website = current_site.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end

  def set_website_picture
    @picture = @website.website_pictures.where(id: params[:id]).first
    redirect_to website_pictures_path, alert: '图片不存在或已删除' unless @picture
  end

end
