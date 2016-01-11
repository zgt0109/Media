class Mobile::ShopBranchesController < Mobile::BaseController
  layout 'mobile/shop_tables'

  def index
    @shop_branches = ShopBranch.order(:id)
  end

  def show
    @shop_branch = ShopBranch.find(params[:id])
  end

  def map
    @shop_branch = ShopBranch.find(params[:id])
    @location = @shop_branch.get_shop_branch_location
  end

  def want_dinner
    @shop_branch = ShopBranch.find(params[:id])
    unless session[:user_id]
      redirect_to four_o_four_url
      return
    end

    unless @shop_branch.shop_menu
      return redirect_to book_dinner_mobile_shops_url(site_id: @site.id), notice: "该分店没有菜单"
    end

    @shop_order = @shop_branch.shop_orders.draft.new(:order_type => 1)

    exist_shop_order = @shop_order.shop_branch.shop_orders.draft.where("user_id = ? AND order_type = ? ", session[:user_id], @shop_order.order_type).first
    if exist_shop_order
      exist_shop_order.destroy
    end
    
    if session[:user_id].nil?
      redirect_to four_o_four_url
      return
    else
      unless session[:user_id]
        redirect_to four_o_four_url 
        return
      end
      if params[:ref_order_id]
        @shop_order = ShopOrder.create(:user_id: session[:user_id], :order_type => 1, :shop_branch_id => @shop_branch.id, :status => ShopOrder::DRAFT, ref_order_id: params[:ref_order_id] ) 
      else
        @shop_order = ShopOrder.create(:user_id: session[:user_id], :order_type => 1, :shop_branch_id => @shop_branch.id, :status => ShopOrder::DRAFT )
      end
    end
    
    redirect_to menu_mobile_shop_order_url(site_id: session[:site_id], id: @shop_order.id)
  end

  def take_out
    @shop_branch = ShopBranch.find(params[:id])
    
    return redirect_to four_o_four_url unless session[:user_id]

    unless @shop_branch.shop_menu
      return redirect_to take_out_mobile_shops_url(site_id: @site.id), notice: "该分店没有菜单"
    end

    @shop_order = @shop_branch.shop_orders.draft.new(:order_type => 2)
    exist_shop_order = @shop_order.shop_branch.shop_orders.draft.where("user_id = ? AND order_type = ? ", session[:user_id], @shop_order.order_type).first
    
    exist_shop_order.destroy if exist_shop_order

    @shop_order = ShopOrder.create(user_id: session[:user_id], order_type: 2, shop_branch_id: @shop_branch.id, status: ShopOrder::DRAFT)
    
    redirect_to menu_mobile_shop_order_url(site_id: session[:site_id], id: @shop_order.id)
  end
end