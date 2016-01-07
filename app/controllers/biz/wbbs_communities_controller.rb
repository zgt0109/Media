class Biz::WbbsCommunitiesController < ApplicationController
  before_filter :require_wx_mp_user
  before_filter :fetch_activity_and_wbbs_community, except: [:index, :new, :create]

  def index
  end

  def edit
  end

  def new
    @activity = current_user.wx_mp_user.new_activity_for_wbbs_community
    @wbbs_community = current_user.wbbs_communities.new
    @wbbs_community.activity = @activity
  end

  def create
    @wbbs_community = current_user.wbbs_communities.new(params[:wbbs_community])
    if @wbbs_community.save
      if params[:type] == 'wx_plot'
        redirect_to wx_plot_owners_path, notice: '保存成功'
      else
        redirect_to wbbs_communities_path, notice: '保存成功'
      end
    else
      render_with_alert "edit", "保存失败，#{@wbbs_community.errors.full_messages.first}"
    end
  end

  def update
    respond_to do |format|
      if @wbbs_community.update_attributes(params[:wbbs_community])
        format.html { redirect_to :back, notice: '更新成功' }
      else
        format.html { redirect_to :back, alert: '更新失败' }
      end
    end
  end

  def destroy
    @wbbs_community.mark_delete!
    redirect_to :back, notice: "操作成功"
  end

  private
    def fetch_activity_and_wbbs_community
      @wbbs_community = current_user.wbbs_communities.find_by_id(params[:id])
      @activity = @wbbs_community.activity
    end
end
