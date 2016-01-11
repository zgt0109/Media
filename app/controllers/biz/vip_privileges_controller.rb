class Biz::VipPrivilegesController < Biz::VipController
  
  before_filter :set_vip_card
  before_filter :find_vip_privilege, only: [:show, :edit, :update, :destroy, :stop]
  before_filter :find_point_types, only: [:new, :edit, :create, :update]

  def index
    @vip_privileges = @vip_card.vip_privileges.show.order('created_at DESC').page(params[:page])
  end

  def new
    @vip_privilege = @vip_card.vip_privileges.new(category: 1, value_by: 1, always_valid: true, amount: "", value: "")
    render :form, layout: 'application_pop'
  end

  def edit
    render :form, layout: 'application_pop'
  end

  def save
    params[:vip_privilege][:category], params[:vip_privilege][:value_by] = params[:category].sub('category_', '').split('_')
    @vip_privilege          ||= @vip_card.vip_privileges.new
    @vip_privilege.attributes = params[:vip_privilege]

    if params[:vip_privilege][:limit_count].to_i == 0
      render_with_alert :form, '可使用次数不能为0', layout: 'application_pop'
    elsif params[:vip_privilege][:vip_grade_ids].blank?
      render_with_alert :form, '请选择适用会员卡等级范围', layout: 'application_pop'
    elsif @vip_privilege.save
      flash.notice = "保存成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :form, "保存失败：#{@vip_privilege.errors.full_messages.join('，')}", layout: 'application_pop'
    end
  end

  alias create save
  alias update save

  def stop
    if @vip_privilege.update_attributes(status: @vip_privilege.active? ? -1 : 1)
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: "操作失败：#{@vip_privilege.errors.full_messages.join('，')}"
    end
  end

  def change_category
    @vip_privilege = @vip_card.vip_privileges.where(id: params[:id]).first
    render partial: params[:category]
  end

  private

    def find_vip_privilege
      @vip_privilege = @vip_card.vip_privileges.find(params[:id])
    end

    def find_point_types
      @point_types = current_site.point_types.normal
    end

end
