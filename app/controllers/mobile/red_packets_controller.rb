class Mobile::RedPacketsController < Mobile::BaseController
  before_filter :require_wx_user, :require_activity, :get_share_image
  before_filter :require_red_packet_release, only: [:new, :create]
  layout 'mobile/red_packets'

  def index
    @red_packet_release = @activity.red_packet_releases.where(user_id: @user.id).first
    @cannot_generate = @activity.activityable.packet_num != -1 && @site.red_packet_releases.where(activity_id: @activity.id).count >= @activity.activityable.packet_num
  end

  def show
    @red_packet_release = @activity.red_packet_releases.find(params[:id])
  end

  def new
    @red_packet_release = @activity.red_packet_releases.new(activity_user: ActivityUser.new)
  end

  def create
    @red_packet_release = @activity.red_packet_releases.new(params[:red_packet_release])
    if @red_packet_release.save
      redirect_to mobile_red_packet_path(@site, @red_packet_release), notice: "领取成功！"
    else
      redirect_to :back, alert: "领取失败：#{@red_packet_release.errors.full_messages.join('\n')}"
    end
  end

  private
  def require_activity
    @activity = @site.activities.find(session[:activity_id])
  end

  def get_share_image
    @share_image = @activity.qiniu_pic_url || @activity.default_pic_url
  rescue => e
    @share_image = qiniu_image_url(Concerns::ActivityQiniuPicKeys::KEY_MAPS[78])
  end

  def require_red_packet_release
    @red_packet_release = @activity.red_packet_releases.where(user_id: @user.id).first
    return redirect_to mobile_red_packets_path, alert: "不可重复领取" if @red_packet_release
    @cannot_generate = @activity.activityable.packet_num != -1 && @site.red_packet_releases.where(activity_id: @activity.id).count >= @activity.activityable.packet_num
    return redirect_to mobile_red_packets_path, alert: "已抢光" if @cannot_generate
  end
end
