class Pro::WxPlotsController < Pro::WxPlotBaseController
  skip_before_filter :require_wx_plot, only: [:index, :create]

  def index
    @wx_plot = current_user.wx_plot
    @wx_plot = WxPlot.new(site_id: current_site.id) if @wx_plot.nil?
  end

  def show
    @activity = current_site.activities.where(activity_type_id: params[:activity_type_id]).first
    @activity = Activity.new(site_id: current_site.id, activity_type_id: params[:activity_type_id], status: Activity::SETTED) if @activity.nil?
  end

  def create
    @wx_plot = WxPlot.new(params[:wx_plot])
    if @wx_plot.save
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: '保存失败'
    end
  end

  def update
    if params[:wx_plot][:wx_plot_categories_attributes].present?
      params[:wx_plot][:wx_plot_categories_attributes].keys.each do |f|
        params[:wx_plot][:wx_plot_categories_attributes].delete(f) if params[:wx_plot][:wx_plot_categories_attributes][f][:name].blank? && params[:wx_plot][:wx_plot_categories_attributes][f][:id].blank?
      end
    end
    if @wx_plot.update_attributes(params[:wx_plot])
      if params[:wx_plot].keys.include?("wx_plot_categories_attributes") || params[:wx_plot].keys.include?("sms_settings_attributes")
        flash[:notice] = "保存成功"
        render inline: "<script>window.parent.location.reload();</script>"
      else
        redirect_to :back, notice: '保存成功'
      end
    else
      redirect_to :back, alert: '保存失败'
    end
  end

end
