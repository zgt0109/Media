class Pro::WxPlotBulletinsController < Pro::WxPlotBaseController

  before_filter :set_bulletin, only: [:edit, :update, :destroy, :done]
  before_filter :set_activity_wx_plot_bulletin

  def index
    @search = @wx_plot.wx_plot_bulletins.order('wx_plot_bulletins.created_at DESC').search(params[:search])
    @bulletins = @search.page(params[:page])
  end

  def new
    @bulletin = @wx_plot.wx_plot_bulletins.new(status: WxPlotBulletin::WAIT)
  end

  def create
    @bulletin = @wx_plot.wx_plot_bulletins.new(params[:wx_plot_bulletin])
    if @bulletin.save
      redirect_to wx_plot_bulletins_path, notice: '添加成功'
    else
      flash[:alert] = '添加失败'
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @bulletin.update_attributes(params[:wx_plot_bulletin])
      redirect_to wx_plot_bulletins_path, notice: '更新成功'
    else
      flash[:alert] = '更新失败'
      render action: 'edit'
    end
  end

  def destroy
    if @bulletin.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def done
    if @bulletin.done!
      redirect_to :back, notice: '发布成功'
    else
      redirect_to :back, notice: '发布成功'
    end
  end

  private

    def set_bulletin
      @bulletin = @wx_plot.wx_plot_bulletins.where(id: params[:id]).first
      return redirect_to wx_plot_bulletins_path, alert: '公告不存在或已删除' unless @bulletin
    end

    def set_activity_wx_plot_bulletin
      @activity_wx_plot_bulletin = @wx_plot.activity_wx_plot_bulletin
      return redirect_to wx_plots_path, alert: "请先设置【#{@wx_plot.bulletin}】模块" unless @activity_wx_plot_bulletin
    end

end
