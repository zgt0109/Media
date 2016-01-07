module App
  class EcategoriesController < BaseController
    layout "app/ebusiness"

    def show
      @category = EcSellerCat.find(params[:id])
      #@items = @category.ec_items.where("ec_shop_id = ?",@category.ec_shop_id).page(params[:page]).per(1)
      @items = @category.show_products.page(params[:page]).per(8)
      @categories = EcSellerCat.root
      respond_to do |format|
        format.html
        format.js()
      end
    end

  end
end
