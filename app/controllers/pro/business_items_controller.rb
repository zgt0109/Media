class Pro::BusinessItemsController < WebsiteShared::WebsiteBaseController
  before_filter :require_business_website, :find_business_shop
  before_filter :find_business_item, only: [:edit, :update, :destroy]
  layout 'application_pop'

  def index
    @business_items = @business_shop.business_items.sorted.page(params[:page])
    render layout: 'application_gm'
  end

  def new
    @business_item = BusinessItem.new
    render :form
  end

  def create
    @business_item = @business_shop.business_items.build params[:business_item]
    if @business_item.save
      render layout: false
    else
      render :form
    end
  end

  def edit
    render :form
  end

  def update
    if @business_item.update_attributes(params[:business_item])
      render layout: false
    else
      render_with_notice :form, '保存失败'
    end
  end

  def destroy
    @business_item.destroy
    render js: "$('#row-#{@business_item.id}').remove(); showTip('success', '操作成功');"
  end

  private
    def find_business_shop
      @business_shop = @website.business_shops.find params[:business_shop_id]
    end

    def find_business_item
      @business_item = @business_shop.business_items.find params[:id]
    end
end