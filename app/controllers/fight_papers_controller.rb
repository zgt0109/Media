class FightPapersController < ApplicationController
  before_filter :find_fight_paper, only: [:show, :edit, :update, :destroy]

  def index
    if params[:activity_id]
      @fight_papers = current_site.fight_papers.where(activity_id: params[:activity_id])
    else
      redirect_to activities_path
    end
  end

  def show
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @fight_paper }
    end
  end

  def new
    @fight_paper = FightPaper.new
    render :index
  end

  def create
    @fight_papers = current_site.fight_papers.where(activity_id: params[:activity_id])
    #logger.info params[:read_time] if params.present?
    if FightPaper.batch_update!(@fight_papers,params)
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败，#{@fight_paper.errors.full_messages.join('，')}"
    end
  end

  def update
    @activity     = current_site.activities.find params[:activity_id]
    @fight_papers = current_site.fight_papers.where(activity_id: params[:activity_id])
    @fight_paper  = @fight_papers.find params[:id]
    if @fight_paper.update_attributes(params[:fight_paper])
      if @activity.setting? && @fight_paper == @activity.fight_papers.last
        @activity.setted!
        redirect_to fights_activities_path
      else
        redirect_to fight_papers_path(activity_id: @fight_paper.activity_id, paper_index: (params[:paper_index].to_i + 1)), notice: '保存成功'
      end
    else
      render_with_alert :index, "保存失败，#{@fight_paper.errors.full_messages.join('，')}"
    end
  end

  def destroy
    @fight_paper.destroy

    respond_to do |format|
      format.html { redirect_to fight_papers_url }
      format.json { head :no_content }
    end
  end

  def user_data
    @total_fight_report_cards = current_site.fight_report_cards.registered.where("fight_report_cards.activity_id = ? AND fight_report_cards.activity_user_id is not null", params[:aid]).includes(:activity_consume).includes(:activity_user).order("fight_report_cards.score DESC, fight_report_cards.speed ASC")
    @search = @total_fight_report_cards.search(params[:search])
    @fight_report_cards = @search.page(params[:page])

    respond_to do |format|
      format.html {render layout: "application_pop"}
      format.xls {
                send_data(FightReportCard.export_excel(@search),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def use_code
    @activity_consume = current_site.activity_consumes.find(params[:id])
    
    if @activity_consume.vip_privilege && @activity_consume.wx_user

      vip_user = @activity_consume.wx_mp_user.vip_users.visible.where(wx_user_id: @activity_consume.wx_user_id).first
      return redirect_to :back, notice:'用户不存在，不可使用' unless vip_user
      return redirect_to :back, notice:'用户已被冻结，不可使用' if vip_user.freeze?
    
      if !@activity_consume.vip_privilege.pending? || @activity_consume.vip_privilege.privilege_status != VipPrivilege::STARTED
        return redirect_to :back, alert: '操作失败，活动已结束，无法使用SN码'
      end
    end
    flash.notice = @activity_consume.use! ? '操作成功' : "操作失败：#{@activity_consume.errors.full_messages.join('，')}"
    render js: "location.reload();"
  end

  private
    def find_fight_paper
      @fight_paper = current_site.fight_papers.find params[:id]
    end
end
