class Pro::BookingAdsController < Pro::BookingBaseController
  before_filter :set_booking_ad, only: [:edit, :update, :destroy]

  def index
    @pictures = @booking.booking_ads
    @picture = @booking.booking_ads.where(id: params[:id]).first || BookingAd.new(booking_id: @booking.id)
  end

  def new
    @picture = @booking.booking_ads.new
    render layout: 'application_pop'
  end

  def create
    @picture = @booking.booking_ads.new(params[:booking_ad])
    if @picture.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.location.href = '#{booking_ads_path}';</script>"
    else
      flash[:notice] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @picture.update_attributes(params[:booking_ad])
      flash[:notice] = "更新成功"
      render inline: "<script>window.parent.location.href = '#{booking_ads_path}';</script>"
    else
      flash[:notice] = "更新失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    if @picture.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  private

  def set_booking_ad
    @picture = @booking.booking_ads.where(id: params[:id]).first
    return redirect_to booking_ads_path, alert: '图片不存在或已删除' unless @picture
  end

end
