class Huodong::WxWallDatasController < ApplicationController
  
  def index
    params[:id] ||= current_user.wx_walls.show.order('id DESC').first.try(:id)
    @wx_wall = current_user.wx_walls.where(id: params[:id]).first
    @wx_wall_users_count = @wx_wall.try(:wx_wall_users).try(:count)
    @vote_users_count = current_user.activity_users.where(activity_id: @wx_wall.try(:vote_id)).count
    @shake_users_count = current_user.wx_shake_users.where(wx_shake_id: @wx_wall.try(:wx_shake_id)).count
    @enroll_users_count = ActivityEnroll.where(activity_id: @wx_wall.try(:enroll_id)).where(["status > -2"]).count
  end

end
