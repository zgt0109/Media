module App
  class EbusinessesController < BaseController

    layout "app/ebusiness"
    before_filter :find_branch

    def index
      @ec_ads = @shop.ads if @shop

    end

    def show
      @item = EcItem.find(params[:id])
    end

    def find_branch
      @shop = EcShop.find_by_id(params[:id])
      @shop_categories = @shop.categories.root if @shop
      @categories = EcSellerCat.root
    end

  end
end
