module App
  class ShopsController < BaseController

    layout 'mobile/shops'

    before_filter :require_wx_user

    def index
      return redirect_to book_table_mobile_shops_url(supplier_id: @wx_mp_user.supplier.id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)  


      # if session[:wx_mp_user_id]
      #   wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
      #   shop = wx_mp_user.shop
      #   @search = shop.shop_branches.used.search(params[:search])
      #   @shop_branches = @search.order(:id).page(params[:page])
      #   #if @shop_branches.count == 1
      #   #  return redirect_to new_app_shop_table_order_url(shop_branch_id: @shop_branches.first.id)
      #   #end
      #   respond_to do |format|
      #     format.html{}
      #     format.js{}
      #   end
      # else
      #   redirect_to four_o_four_url
      # end 

    end

    def book_dinner
      return redirect_to book_dinner_mobile_shops_url(supplier_id: @wx_mp_user.supplier.id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)  
      # wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
      # shop = wx_mp_user.shop
      # @search = shop.shop_branches.used.search(params[:search])
      # @shop_branches = @search.order(:id).page(params[:page])
      # #if @shop_branches.count == 1
      # #  return redirect_to want_dinner_app_shop_branch_url(@shop_branches.first)
      # #end
      # respond_to do |format|
      #   format.html{}
      #   format.js{}
      # end
    end

    def take_out
      return redirect_to take_out_mobile_shops_url(supplier_id: @wx_mp_user.supplier.id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)  
      # wx_mp_user = WxMpUser.find(session[:wx_mp_user_id])
      # shop = wx_mp_user.shop
      # @search = shop.shop_branches.used.search(params[:search])
      # @shop_branches = @search.order(:id).page(params[:page])
      # #if @shop_branches.count == 1
      # #  return redirect_to take_out_app_shop_branch_url(@shop_branches.first)
      # #end
      # respond_to do |format|
      #   format.html{}
      #   format.js{}
      # end
    end

  end
end