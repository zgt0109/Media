class Biz::VipMessagePlansController < Biz::VipController
  before_filter :find_vip_message_plan, only: [:edit, :update, :show]

  def index
    @search            = current_site.vip_card.vip_message_plans.order('created_at DESC').search(params[:search])
    @status_eq         = params[:search][:status_eq].to_i rescue 0
    @given_group_id_eq = params[:search][:given_group_id_eq].to_i rescue ''
    @plans             = @search.page(params[:page])
  end

  def new
    @plan = current_site.vip_card.vip_message_plans.build
    render :form, layout: 'application_pop'
  end

  def create
    @plan = current_site.vip_card.vip_message_plans.new params[:vip_message_plan]
    save_vip_message_plan
  end

  def edit
    @plan = current_site.vip_card.vip_message_plans.find params[:id]
    render :form, layout: 'application_pop'
  end

  def update
    @plan.attributes = params[:vip_message_plan]
    save_vip_message_plan
  end

  def show
    @plan = current_site.vip_card.vip_message_plans.find params[:id]
    render layout: 'application_pop'
  end

  private
  def find_vip_message_plan
    @plan = current_site.vip_card.vip_message_plans.find params[:id]
  end

  def save_vip_message_plan
    if @plan.save
      VipMessagePlanWorker.send_message(@plan)
      flash[:notice] = '保存成功'
      render inline: '<script>window.parent.location.reload();</script>'
    else
      flash[:alert] = "保存失败，#{@plan.full_error_message}"
      render :form, layout: 'application_pop'
    end
  end
end
