class Huodong::WxWallUserPrizesController < ApplicationController
  
  before_filter :get_wall

  def index
    @search = @wx_wall.wx_wall_prizes_wx_wall_users.show.search(params[:search])
    @wx_wall_prizes_wx_wall_users = @search.page(params[:page])
    @status = params[:search][:status_eq] if params[:search]
  end

  def edit
    render layout: 'application_pop'
  end

  def update
    @wx_wall_prizes_wx_wall_user = @wx_wall.wx_wall_prizes_wx_wall_users.where(sn_code: params[:sn_code]).first
    if @wx_wall_prizes_wx_wall_user.present? && @wx_wall_prizes_wx_wall_user.pending?
      return redirect_to exchange_prize_wx_wall_user_prize_path(@wx_wall.id, user_prize_id: @wx_wall_prizes_wx_wall_user.id)
    elsif @wx_wall_prizes_wx_wall_user.present? && @wx_wall_prizes_wx_wall_user.awarded?
      return redirect_to :back, alert: '该SN码已被使用过'
    else
      return redirect_to :back, alert: '没有该SN码，请重新核对后输入！'
    end
  end

  def exchange_prize
    @wx_wall_prizes_wx_wall_user = @wx_wall.wx_wall_prizes_wx_wall_users.find(params[:user_prize_id])
    @wx_wall_prize = @wx_wall_prizes_wx_wall_user.try(:wx_wall_prize)
    render layout: 'application_pop'
  end

  def update_user_prize
    @wx_wall_prizes_wx_wall_user = @wx_wall.wx_wall_prizes_wx_wall_users.find(params[:user_prize_id])
    if @wx_wall_prizes_wx_wall_user.present? && @wx_wall_prizes_wx_wall_user.update_attributes(status: WxWallPrizesWxWallUser::AWARDED)
      flash[:notice] = "领取成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      return redirect_to :back, alert: '领取失败'
    end
  end

  private

  def get_wall
    @wx_wall = current_user.wx_walls.find(params[:id])
    return redirect_to wx_walls_path, alert: '请先添加微信墙活动' unless @wx_wall
  end

end
