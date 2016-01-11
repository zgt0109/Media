class Huodong::RedPacket::ReleasesController < ApplicationController
  before_filter :require_red_packet_setting
  before_filter :find_activities

  def consumes
    @total_releases = current_site.red_packet_releases
    @search = @total_releases.search(params[:search])
    @releases= @search.order("id DESC").page(params[:page])

    respond_to :html, :xls
  end

  def find_consume
    @release = ::RedPacket::Release.find_by_id(params[:id])
    @shop_branches = current_site.shop_branches.used
    @consume = @release.consume
    render layout: 'application_pop'
  end

  def use_consume
    @consume = current_site.wx_mp_user.consumes.unused.unexpired.find(params[:id])
    shop_branch = ShopBranch.find_by_id(params[:shop_branch_id])
    @consume.use!(shop_branch)
    flash.notice = '核销成功'
    render js: "parent.location.reload();"
  end

  private
    def find_activities
      @activities = current_site.red_packet_activities.order("id DESC").page(params[:page])
      @activity_plucks = @activities.pluck(:name, :id)
    end

    def require_red_packet_setting
      @red_packet = current_site.red_packet_setting
      redirect_to new_red_packet_packet_path, alert: "请先进行活动设置！" unless @red_packet
    end
end
