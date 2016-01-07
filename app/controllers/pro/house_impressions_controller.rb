class Pro::HouseImpressionsController < Pro::HousesBaseController

  def index
    @impressions = current_user.house.impressions.where(predefined: true).order('ratio desc').page(params[:page])
    @activity = current_user.wx_mp_user.create_activity_for_house_impression
  end

  def activity
    @activity = current_user.wx_mp_user.create_activity_for_house_impression
  end

  def update_activity
    @activity = current_user.wx_mp_user.create_activity_for_house_impression
    if @activity.update_attributes(params[:activity])
      redirect_to house_impressions_path, notice: '保存成功'
    else
      flash[:alert] = '保存失败'
      redirect_to house_impressions_path
    end
  end

  def new
    @impression = HouseImpression.new
    render layout: 'application_pop'
  end

  def create
    @impression = current_user.house.impressions.build(params[:house_impression].merge(predefined: true))
    if @impression.save
    flash[:notice] = "保存成功"
    render inline: "<script>parent.location.reload();</script>"
    else
      return redirect_to :back , alert: '保存失败'
    end
  end

  def edit
    @impression = current_user.house.impressions.find(params[:id])
    render layout: 'application_pop'
  end

  def update
    @impression = current_user.house.impressions.find(params[:id])
    if @impression.update_attributes(params[:house_impression])
      flash[:notice] = "保存成功"
    #  render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      render inline: "<script>parent.location.reload();</script>"
    else
      return redirect_to :back , alert: '保存失败'
    end
  end

  def destroy
    @impression = current_user.house.impressions.find(params[:id])
    @impression.destroy
    redirect_to house_impressions_path(anchor: "tab-2"), notice: '操作成功'
  end

end
