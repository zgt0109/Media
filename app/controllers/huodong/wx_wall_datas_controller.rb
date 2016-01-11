class Huodong::WxWallDatasController < ApplicationController
  
  def index
    params[:id] ||= current_site.wx_walls.show.order('id DESC').first.try(:id)
    @wx_wall = current_site.wx_walls.where(id: params[:id]).first
    @wx_wall_users_count = @wx_wall.try(:wx_wall_users).try(:count)
    @vote_users_count = current_site.activity_users.where(activity_id: @wx_wall.try(:vote_id)).count
    @shake_users_count = current_site.shake_users.where(shake_id: @wx_wall.try(:shake_id)).count
    @enroll_users_count = ActivityEnroll.where(activity_id: @wx_wall.try(:enroll_id)).where(["status > -2"]).count
  end

end
