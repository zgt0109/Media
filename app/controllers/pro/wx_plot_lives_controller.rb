class Pro::WxPlotLivesController < Pro::WxPlotBaseController

  before_filter :set_life, only: [:edit, :update, :destroy]
  before_filter :set_activity_wx_plot_life
  def index
    @search = @wx_plot.wx_plot_lives.order('created_at DESC').search(params[:search])
    @lives = @search.page(params[:page])
  end

  def new
    @life = @wx_plot.wx_plot_lives.new
  end

  def create
    @life = @wx_plot.wx_plot_lives.new(params[:wx_plot_life])
    if @life.save
      redirect_to wx_plot_lives_path, notice: '添加成功'
    else
      flash[:alert] = "添加失败"
      render action: 'new'#, layout: 'application_pop'
    end
  end

  def edit

  end

  def update
    if @life.update_attributes(params[:wx_plot_life])
      redirect_to wx_plot_lives_path, notice: '更新成功'
    else
      flash[:alert] = "更新失败"
      render action: 'edit'#, layout: 'application_pop'
    end
  end

  def destroy
    if @life.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  private

    def set_life
      @life = @wx_plot.wx_plot_lives.where(id: params[:id]).first
      return redirect_to wx_plot_lives_path, alert: '记录不存在或已删除' unless @life
    end

    def set_activity_wx_plot_life
      @activity_wx_plot_life = current_site.activity_wx_plot_life
      return redirect_to wx_plots_path, alert: "请先设置【#{@wx_plot.life}】模块" unless @activity_wx_plot_life
      @categories = @wx_plot.life_categories
    end

end
