class Mobile::EcCategoriesController < Mobile::BaseController
  layout 'mobile/ec'

  def show
    @page_class = "list"
    @category = @site.ec_shop.categories.find(params[:id])
    @items = Kaminari.paginate_array(@category.products).page(params[:page]).per(10)
    #@categories = EcSellerCat.root
    respond_to do |format|
      format.html
      format.js()
    end
  end

end
