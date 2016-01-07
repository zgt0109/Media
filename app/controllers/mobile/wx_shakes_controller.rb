class Mobile::WxShakesController < Mobile::BaseController
	layout 'mobile/shake'
  before_filter :block_non_wx_browser

  def index
  	@wx_shake = @supplier.activities.shake.find(session[:activity_id]).activityable
	  @wx_shake_user = @wx_shake.wx_shake_users.where(wx_user_id: session[:wx_user_id]).first if @wx_shake
	  render_404 unless @wx_shake_user && @wx_shake.normal?
  end

  def show
    @wx_shake = @supplier.wx_shakes.find params[:id]
    @activity = @wx_shake.activity
    @wx_shake_prizes = @wx_shake.wx_shake_prizes.includes(:wx_shake_round).where(wx_user_id: session[:wx_user_id]).order('id DESC')
  end

end