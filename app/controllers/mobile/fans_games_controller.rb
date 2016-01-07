class Mobile::FansGamesController < Mobile::BaseController
	layout 'mobile/fans_game'
  before_filter :block_non_wx_browser, :require_wx_mp_user

	def index
		@activity = @supplier.activities.where(activity_type_id: 67).first
		@activities_fans_games = @activity.activities_fans_games.turn_up.latest
		@share_image = "#{MOBILE_DOMAIN}/assets/activity_pics/67.jpg"
	end

	def show
		return redirect_to mobile_notice_url(msg: '请求页面参数不正确')
		case params[:id]
		when "1" then render :game_1, layout: false
		when "2" then render :game_2, layout: false
		when "3" then render :game_3, layout: false
		when "4" then render :game_4, layout: false
		when "5" then render :game_5, layout: false
		when "6" then render :game_6, layout: false
		when "7" then render :game_7, layout: false
		when "8" then render :game_8, layout: false
		when "9" then render :game_9, layout: false
		when "10" then render :game_10, layout: false
		when "11" then render :game_11, layout: false
		else redirect_to mobile_notice_url(msg: '请求页面参数不正确')
		end
	end
	
end