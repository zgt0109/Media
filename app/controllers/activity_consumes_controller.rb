class ActivityConsumesController < ApplicationController

  def index
    @total_activity_consumes = current_user.activity_consumes.joins(:vip_privilege).order("activity_consumes.id desc")
    @search = @total_activity_consumes.search(params[:search])
    @activity_consumes = @search.page(params[:page])
  end

  def show
    @shop_branches = current_user.shop_branches.used
    render layout: 'application_pop'
  end


  def used
    @activity_consume = current_user.activity_consumes.find(params[:id])
    
    if @activity_consume.vip_privilege && @activity_consume.wx_user

      vip_user = @activity_consume.wx_mp_user.vip_users.visible.where(wx_user_id: @activity_consume.wx_user_id).first
      return redirect_to :back, notice:'用户不存在，不可使用' unless vip_user
      return redirect_to :back, notice:'用户已被冻结，不可使用' if vip_user.freeze?
    
      if !@activity_consume.vip_privilege.pending? || @activity_consume.vip_privilege.privilege_status != VipPrivilege::STARTED
        return redirect_to :back, alert: '操作失败，活动已结束，无法使用SN码'
      end
    end
    flash.notice = @activity_consume.use!(params[:shop_branch_id]) ? '操作成功' : "操作失败：#{@activity_consume.errors.full_messages.join('，')}"
    respond_to do |format|
      format.js {render js: "parent.location.reload();"}
      format.html {redirect_to :back}
    end
  end

end
