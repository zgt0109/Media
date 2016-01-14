class Pro::WxPlotCategoriesController < Pro::WxPlotBaseController

  layout 'application_pop'
  before_filter :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = @wx_plot.wx_plot_categories.where(category: params[:category].to_s.split(',').map(&:to_i))
    @categories << @wx_plot.wx_plot_categories.new(category: params[:category].to_s.split(',').map(&:to_i).first)
  end

  def sms_setting
    @categories = @wx_plot.wx_plot_categories.where(category: params[:category].to_s.split(',').map(&:to_i))
    @sms_settings = @wx_plot.sms_settings.where(wx_plot_category_id: @categories.collect(&:id))
    @sms_settings << @wx_plot.sms_settings.new if @sms_settings.blank?
    @system_message_setting = current_user.system_message_settings.includes(:system_message_module).where(["system_message_modules.module_id = ?", params[:module_id]]).first_or_initialize(site_id: current_site.id, system_message_module_id: SystemMessageModule.where(module_id: params[:module_id]).first.id)
  end

  private
    def set_category
      @category = @wx_plot.wx_plot_categories.where(id: params[:id]).first
      return render json: {type: 'warning', info: '类别不存在或已删除'} unless @category
    end
end
