module App
  class ShopBranchesController < BaseController
    layout 'mobile/shop_tables'
    before_filter :require_wx_mp_user, :find_wx_user

    def index
      return redirect_to book_table_mobile_shops_url(supplier_id: @wx_mp_user.supplier_id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)
    end

    def show
      @shop_branch = ShopBranch.find(params[:id])
    end

    def map
      @shop_branch = ShopBranch.find(params[:id])
      @location = @shop_branch.get_shop_branch_location
    end

    def want_dinner
      return redirect_to book_dinner_mobile_shops_url(supplier_id: @wx_mp_user.supplier_id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)
    end

    def take_out
      return redirect_to take_out_mobile_shops_url(supplier_id: @wx_mp_user.supplier_id, id: params[:id], aid: params[:aid], openid: @wx_user.openid, wxmuid: @wx_mp_user.id)
    end

    private
      def find_wx_user
        @wx_user = @wx_mp_user.wx_users.find(session[:wx_user_id])
      end

  end
end