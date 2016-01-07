module App
  class MicroStoresController < BaseController
   
    before_filter :find_micro_store, only: :show

    layout "app/micro_stores"

    def index
      @search = ShopBranch.used.where(wx_mp_user_id: session[:wx_mp_user_id]).search(params[:search]).params[:page]
      @shop_branches = @search.order(:id)
    end
    
    def show
      @shop_branch = ShopBranch.find(params[:id])

      case params[:ref]
      when "dinner"
        @href = book_dinner_app_shops_url
      when "out"
        @href = take_out_app_shops_url
      when "table"
        @href = app_shops_url
      else
        @href = app_micro_stores_url
      end
      @location = @shop_branch.get_shop_branch_location
    end

    def map
      return render text: '参数不正确' unless session[:wx_mp_user_id]
      
      @search = ShopBranch.used.where(wx_mp_user_id: session[:wx_mp_user_id]).search(params[:search])
      @shop_branches = @search.order(:id)
      if @shop_branches.count == 0
        redirect_to four_o_four_url  
      else
        render 'index_map'
      end
    end

    def list
      return render text: '参数不正确' unless session[:wx_mp_user_id]
      
      @search = ShopBranch.used.where(wx_mp_user_id: session[:wx_mp_user_id]).search(params[:search])
      @shop_branches = @search.order(:id)
      render 'index'
    end

    private
    def find_micro_store
      @micro_store = ShopBranch.where(id: params[:id]).first
      return render text: '微门店不存在' unless @micro_store
    end

  end
end
