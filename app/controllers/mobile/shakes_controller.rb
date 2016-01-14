class Mobile::ShakesController < Mobile::BaseController
  layout 'mobile/shake'
  before_filter :block_non_wx_browser

  def index
    @shake = @site.activities.shake.find(session[:activity_id]).activityable
    @shake_user = @shake.shake_users.where(user_id: session[:user_id]).first if @shake
    render_404 unless @shake_user && @shake.normal?
  end

  def show
    @shake = @site.shakes.find params[:id]
    @activity = @shake.activity
    @shake_prizes = @shake.shake_prizes.includes(:shake_round).where(user_id: session[:user_id]).order('id DESC')
  end

end