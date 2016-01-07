class Pro::BusinessShopPicturesController < WebsiteShared::WebsiteBaseController
  before_filter :require_business_website, :find_business_shop

  def index
    @business_shop_pictures = @business_shop.business_shop_pictures.recent.page(params[:page]).per(9)
  end

  def create
    params[:picture] =  params[:picture].first if params[:picture].is_a?(Array)
    @picture = @business_shop.business_shop_pictures.create(pic: params[:picture].tempfile)
    render nothing: true
  end

  def destroy
    @business_shop_picture = @business_shop.business_shop_pictures.find params[:id]
    @business_shop_picture.destroy
    render js: "$('#picture-#{@business_shop_picture.id}').remove(); showTip('success', '操作成功');"
  end

  private
    def find_business_shop
      @business_shop = @website.business_shops.find params[:business_shop_id]
    end
end
