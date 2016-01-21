class Pro::WxPlotTelephonesController < Pro::WxPlotBaseController

  before_filter :set_phone, only: [:edit, :update, :destroy]
  before_filter :set_activity_wx_plot_telephone
  def index
    @search = @wx_plot.wx_plot_telephones.order('created_at DESC').search(params[:search])
    @phones = @search.page(params[:page])
  end

  def new
    @phone = @wx_plot.wx_plot_telephones.new
    render layout: 'application_pop'
  end

  def create
    @phone = @wx_plot.wx_plot_telephones.new(params[:wx_plot_telephone])
    if @phone.save
      flash[:notice] = "添加成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      flash[:alert] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    if @phone.update_attributes(params[:wx_plot_telephone])
      flash[:notice] = "更新成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      flash[:alert] = "更新失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def destroy
    if @phone.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  private

    def set_phone
      @phone = @wx_plot.wx_plot_telephones.where(id: params[:id]).first
      return redirect_to wx_plot_telephones_path, alert: '常用电话不存在或已删除' unless @phone
    end

    def set_activity_wx_plot_telephone
      @activity_wx_plot_telephone = @wx_plot.activity_wx_plot_telephone
      return redirect_to wx_plots_path, alert: "请先设置【#{@wx_plot.telephone}】模块" unless @activity_wx_plot_telephone
      @categories = @wx_plot.telephone_categories
    end

end
