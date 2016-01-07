class Biz::VipPackageItemsController < Biz::VipController

  before_filter :set_vip_card
  before_filter :find_vip_package_item, only: [:edit, :update, :destroy]

  def index
    @search = @vip_card.vip_package_items.normal.latest.search(params[:search])
    @package_items = @search.page(params[:page])
  end

  def new
    @vip_package_item = @vip_card.vip_package_items.new
    render :form
  end

  def edit
    render :form
  end

  def create
    @vip_package_item = @vip_card.vip_package_items.new(params[:vip_package_item].merge!(supplier_id: @vip_card.supplier_id, wx_mp_user_id: @vip_card.wx_mp_user_id))
    if @vip_package_item.save
      redirect_to vip_package_items_path, notice: '保存成功'
    else
      render_with_alert :form, '保存失败'
    end
  end

  def update
    if @vip_package_item.update_attributes(params[:vip_package_item])
      flash[:notice] = "保存成功"
      redirect_to vip_package_items_path, notice: '保存成功'
    else
      render_with_alert :form, '保存失败'
    end
  end

  def destroy
  	@vip_package_item.update_attributes(status: VipPackageItem::DELETED)
  	render js: "$('#item-#{@vip_package_item.id}').remove();"
  end

  private

    def find_vip_package_item
      @vip_package_item = @vip_card.vip_package_items.where(id: params[:id]).first
    end
end