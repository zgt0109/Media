class Mobile::WxPlotsController < Mobile::BaseController

  layout 'mobile/wx_plot'

  before_filter :require_wx_user, only: [:repair_complains, :repair_complain, :new_repair_complain, :create_repair_complain, :cancel_repair_complain, :repair_complain_message]
  before_filter :set_wx_plot
  before_filter :set_wx_plot_repair_complains, only: [:repair_complains, :repair_complain, :new_repair_complain, :create_repair_complain, :cancel_repair_complain, :repair_complain_message]
  before_filter :set_wx_plot_repair_complain, only: [:repair_complain, :cancel_repair_complain, :repair_complain_message]
  before_filter :set_site_website, only: [:bulletins, :bulletin]

  def bulletins
    @share_image = @wx_plot.cover_pic.present? ? @wx_plot.cover_pic : @site.activity_wx_plot_bulletin.try(:qiniu_pic_url)
    @bulletins = @wx_plot.wx_plot_bulletins.order('wx_plot_bulletins.done_date_at DESC').done
    render layout: 'mobile/wx_plot_website'
  end

  def bulletin
    @bulletin = @wx_plot.wx_plot_bulletins.done.where(id: params[:id]).first
    @share_image = @bulletin.pic.present? ? @bulletin.pic : @site.activity_wx_plot_bulletin.try(:qiniu_pic_url)
    render layout: 'mobile/wx_plot_website'
    return redirect_to bulletins_mobile_wx_plots_path(anchor: 'mp.weixin.qq.com'), alert: "相关#{@wx_plot.bulletin}记录不存在" unless @bulletin
  end

  def repair_complains
    @share_image = params[:type] == 'repair' ? @site.activity_wx_plot_repair.try(:qiniu_pic_url) : @site.activity_wx_plot_complain.try(:qiniu_pic_url)
  end

  def repair_complain
    @share_image = params[:type] == 'repair' ? @site.activity_wx_plot_repair.try(:qiniu_pic_url) : @site.activity_wx_plot_complain.try(:qiniu_pic_url)
    @message = @repair_complain.messages.new(messageable_id: session[:user_id], messageable_type: 'WxUser')
  end

  def new_repair_complain
    @share_image = params[:type] == 'repair' ? @site.activity_wx_plot_repair.try(:qiniu_pic_url) : @site.activity_wx_plot_complain.try(:qiniu_pic_url)
    @categories = params[:type] == 'repair' ? @wx_plot.repair_categories : @wx_plot.complain_advice_categories
    return render_404 if @categories.nil?
    @repair_complain = @repair_complains.new({wx_plot_id: @wx_plot.id, user_id: @user.id, status: 0}.merge!(session[params[:type].to_sym].to_h))
  end

  def create_repair_complain
    session[params[:type].to_sym] = {
        nickname: params[:wx_plot_repair_complain][:nickname],
        phone: params[:wx_plot_repair_complain][:phone],
        room_no: params[:wx_plot_repair_complain][:room_no],
    }
    @repair_complain = @repair_complains.new(params[:wx_plot_repair_complain])
    if @repair_complain.save
      @site.send_system_message({site_id: @site.id, content: "#{@repair_complain.created_at.strftime('%H:%M')}收到#{@repair_complain.nickname}用户#{@repair_complain.phone}的#{@repair_complain.wx_plot_category.name}#{@repair_complain.repair? ? '报修申请' : '投诉建议'}", module_id: @repair_complain.repair? ? 1 : 2 }, SystemMessageModule.where(module_id: @repair_complain.repair? ? 1 : 2).first)
      redirect_to repair_complains_mobile_wx_plots_path(type: params[:type], anchor: 'mp.weixin.qq.com'), notice: '提交成功'
    else
      redirect_to :back, alert: '提交失败'
    end
  end

  def repair_complain_message
    @message = @repair_complain.messages.new(params[:wx_plot_repair_complain_message])
    if @message.save
      redirect_to :back, notice: '留言成功'
    else
      redirect_to :back, notice: '留言失败'
    end
  end

  def cancel_repair_complain
    if @repair_complain.cancel!
      redirect_to repair_complains_mobile_wx_plots_path(type: params[:type], anchor: 'mp.weixin.qq.com'), notice: '取消成功'
    else
      redirect_to :back, alert: '取消失败'
    end
  end

  def telephones
    @share_image = @site.activity_wx_plot_telephone.try(:qiniu_pic_url)
    @categories = @wx_plot.telephone_categories
    @phones = @wx_plot.wx_plot_telephones
  end

  def lives
    @share_image = @site.activity_wx_plot_life.try(:qiniu_pic_url)
    @categories = @wx_plot.life_categories
    @lives = @wx_plot.wx_plot_lives
  end

  def life
    @share_image = @site.activity_wx_plot_life.try(:qiniu_pic_url)
    @life = @wx_plot.wx_plot_lives.where(id: params[:id]).first
    return redirect_to lives_mobile_wx_plots_path(anchor: 'mp.weixin.qq.com'), alert: "相关#{@wx_plot.life}记录不存在" unless @life
  end

  def owners
    @share_image = @site.activity_wx_plot_owner.try(:qiniu_pic_url)
    @owners = @site.wbbs_communities.setted
  end


  private

    def set_wx_plot
      @wx_plot = @site.wx_plot
    end

    def set_wx_plot_repair_complains
      @repair_complains = params[:type] == 'repair' ? @wx_user.repairs.show : @wx_user.complain_advices.show
    end

    def set_wx_plot_repair_complain
      @repair_complain = @repair_complains.where(id: params[:id]).first
      return redirect_to repair_complains_mobile_wx_plots_path(type: params[:type], anchor: 'mp.weixin.qq.com'), alert: "相关#{@wx_plot[params[:type]]}记录不存在" unless @repair_complain
    end

    def set_site_website
      @website_setting = @site.website.try(:website_setting)
      @list_template_id = params[:list_template_id].presence.try(:to_i) || (@website_setting.nil? ? 1 : @website_setting.list_template_id.to_i)
      @detail_template_id = params[:detail_template_id].presence.try(:to_i) || (@website_setting.nil? ? 1 : @website_setting.detail_template_id.to_i)
    end

end
