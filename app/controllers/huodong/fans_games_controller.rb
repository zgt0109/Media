class Huodong::FansGamesController < ApplicationController
	before_filter :require_wx_mp_user
	before_filter :find_activity, except: [ :create ]
	
	def index
    @activity ||= current_site.activities.new(activity_type_id:67)
	end

	def show
		FansGame.pluck(:id).each{|id| @activity.activities_fans_games.where(fans_game_id: id).first_or_create }
		@fans_games = FansGame.show.latest
		@ids = @activity.activities_fans_games.turn_up.pluck(:fans_game_id)
	end

	def create
		@activity = current_site.activities.new(params[:activity])
		@activity.wx_mp_user_id = current_user.wx_mp_user.id
		@activity.activity_type_id = 67
		@activity.status = 1
		if @activity.save
			redirect_to fans_games_path, notice: "保存成功"
		else
			render_with_alert :index, "保存失败，#{@activity.errors.full_messages.first}"
		end
	end

	def update
		if @activity.update_attributes(params[:activity])
			redirect_to fans_games_path, notice: "保存成功"
		else
			render_with_alert :index, "保存失败，#{@activity.errors.full_messages.first}"
		end
	end

	def destroy
		fans_games_activitie = @activity.activities_fans_games.where(fans_game_id: params[:id]).first
    fans_games_activitie.up_status!
    render js: "showTip('success', '操作成功')"
	end

	private
    def find_activity
      @activity = current_site.activities.fans_game.first
    end
end