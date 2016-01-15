class Biz::WbbsTopicsController < ApplicationController
  before_filter :fetch_wbbs_community

  def index
    @topics = @wbbs_community.wbbs_topics.normal.order('created_at DESC').page(params[:page])
  end

  def removed
    @topics = @wbbs_community.wbbs_topics.deleted.order('created_at DESC').page(params[:page])
  end

  def destroy
    @topic = @wbbs_community.wbbs_topics.normal.find(params[:id])
    if @topic.deleted!
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: '删除失败'
    end
  end

  def normal
    @topic = @wbbs_community.wbbs_topics.find(params[:id])
    if @topic.normal!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作成功'
    end
  end

  #置顶
  def stickie
    @topic = @wbbs_community.wbbs_topics.normal.find(params[:id])
    if @topic.toggle! :top
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def normal_users
    @users = @wbbs_community.normal_users.page(params[:page])
  end

  def forbidden_users
    @users = @wbbs_community.forbidden_users.page(params[:page])
  end

  def forbid_user
    @user = @wbbs_community.normal_users.find(params[:id])
    @user.update_column(:leave_message_forbidden, true)
    flash[:notice] = "已屏蔽该用户"
    redirect_to :back
  end

  def cancel_forbid_user
    @user = @wbbs_community.forbidden_users.find(params[:id])
    @user.update_column(:leave_message_forbidden, false)
    flash[:notice] = "已取消屏蔽该用户"
    redirect_to :back
  end

  private
    def fetch_wbbs_community
      @wbbs_community = current_site.wbbs_communities.find_by_id(params[:community_id])
    end

end
