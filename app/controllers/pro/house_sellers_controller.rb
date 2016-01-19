class Pro::HouseSellersController < Pro::HousesBaseController
  before_filter :find_seller, only: [:edit, :destroy, :update]

  def index
    load_sellers
  end

  def activity
    @activity = current_site.create_activity_for_house_seller
  end

  def update_activity
    @activity = current_site.create_activity_for_house_seller
    if @activity.update_attributes(params[:activity])
      #redirect_to activity_house_sellers_path, notice: '保存成功'
      redirect_to house_sellers_path, notice: '保存成功'
    else
      render :activity
    end
  end

  def create
    @seller = current_site.house.sellers.build(params[:house_seller])
    if @seller.save
    flash[:notice] = "保存成功"
    render inline: "<script>parent.location.reload();</script>"
    else
      return redirect_to :back , alert: '保存失败，请确认数据正确和必填项。'
    end
  end

  def new
    @seller = HouseSeller.new
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @seller.update_attributes(params[:house_seller])
      flash[:notice] = "保存成功"
      #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      render inline: "<script>parent.location.reload();</script>"
      #redirect_to house_sellers_path(anchor: 'tab-2')
    else
      return redirect_to :back , alert: '保存失败'
    end
  end

  def destroy
    @seller.update_attributes(status: HouseSeller::DELETED)
    redirect_to house_sellers_path(anchor: 'tab-2'), notice: '操作成功'
  end

  private
  def load_sellers
    @sellers = current_site.house.sellers.normal.order('created_at DESC').page(params[:page])
  end

  def find_seller
    @seller = current_site.house.sellers.normal.find params[:id]
  end

end
