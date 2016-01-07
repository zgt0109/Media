# -*- coding: utf-8 -*-
class Pro::EcAdsController < Pro::EcBaseController
  layout 'application_gm'

  before_filter :set_website
  before_filter :set_ec_ad, only: [:show, :edit, :update, :destroy]

  def index
    @pictures = @ec_shop.ads
    @picture = @ec_shop.ads.where(id: params[:id]).first || EcAd.new
  end


  def new
    @picture = @ec_shop.ads.new
    @ec_seller_cat_selects = @ec_shop.multilevel_menu params
    render layout: 'application_pop'
  end

  def create
    @picture = @ec_shop.ads.new(params[:ec_ad])

    if @picture.product?
      @picture.menuable_id = params[:ec_ad][:ec_item_id]
      @picture.menuable_type = "EcItem"
      unless @picture.menuable.present?
        flash[:alert] = "添加失败, 商品不存在"
        @ec_seller_cat_selects = @ec_shop.multilevel_menu params
        render action: 'new', layout: 'application_pop'
        return
      end
    end

    if @picture.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "添加失败"
      @ec_seller_cat_selects = @ec_shop.multilevel_menu params
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    @picture.seller_cid = @picture.menuable_id if @picture.category?
    @picture.ec_item_id = @picture.menuable_id if @picture.product?
    @picture.activity_id = @picture.menuable_id if @picture.activity?
    @ec_seller_cat_selects = @picture.category? ? @picture.multilevel_menu(params) : @ec_shop.multilevel_menu(params)
    render layout: 'application_pop'
  end

  def update
    @picture.attributes = params[:ec_ad]

    if @picture.product?
      @picture.menuable_id = params[:ec_ad][:ec_item_id]
      @picture.menuable_type = "EcItem"
      unless @picture.menuable.present?
        flash[:alert] = "更新失败, 商品不存在"
        @ec_seller_cat_selects = @ec_shop.multilevel_menu params
        render action: 'new', layout: 'application_pop'
        return
      end
    end

    if @picture.update_attributes(params[:ec_ad])
      flash[:notice] = "更新成功"
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    else
      flash[:alert] = "更新失败"
      @ec_seller_cat_selects = @picture.category? ? @picture.multilevel_menu(params) : @ec_shop.multilevel_menu(params)
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    if @picture.destroy
      render json: {id: params[:id]}
    else
      render text: '删除失败'
    end
  end

  private

  def set_website
    @ec_shop = current_user.ec_shop
  end

  def set_ec_ad
    @picture = @ec_shop.ads.find(params[:id])
  end

end
