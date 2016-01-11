class Pro::WxPlotRepairComplainsController < Pro::WxPlotBaseController

  before_filter :set_repair_complain, only: [:show, :reply, :change, :update]
  before_filter :set_activity_wx_plot_repair_complain

  def index
    @search = params[:type] == 'repair' ? @wx_plot.repairs.order('created_at DESC').search(params[:search]) :  @wx_plot.complain_advices.order('created_at DESC').search(params[:search])
    @categories = params[:type] == 'repair' ? @wx_plot.repair_categories : @wx_plot.complain_advice_categories
    @repair_complains = @search.page(params[:page])
  end

  def show
    render layout: 'application_pop'
  end

  def reply
    @message = @repair_complain.messages.new(messageable_id: current_user.id, messageable_type: 'Account')
    @messages = @repair_complain.messages + @repair_complain.statuses
    @messages = @messages.reject{|f| f.new_record? }.sort{|x, y| x.created_at <=> y.created_at}
    render layout: 'application_pop'
  end

  def change
    render layout: 'application_pop'
  end

  def update
    if @repair_complain.update_attributes(params[:wx_plot_repair_complain])
      flash[:notice] = "操作成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      redirect_to :back, alert: "操作失败"
    end
  end

  private
    def set_repair_complain
      @repair_complain = @wx_plot.wx_plot_repair_complains.where(id: params[:id]).first
      return redirect_to wx_plot_repair_complains_path, alert: '记录不存在或已删除' unless @repair_complain
    end

    def set_activity_wx_plot_repair_complain
      @activity_wx_plot_repair_complain = params[:type] == 'repair' ? current_user.activity_wx_plot_repair : current_user.activity_wx_plot_complain
      return redirect_to wx_plots_path, alert: "请先设置【#{@wx_plot[params[:type]]}】模块" unless @activity_wx_plot_repair_complain
    end
end
