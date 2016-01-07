json.cnt_followings @wx_user.following_by_type("Wmall::Shop").where(mall_id: current_mall.id).count
json.usable_points @usable_points
json.points_url points_app_vips_path(type: "out", wxmuid: current_wx_mp_user.try(:id))
