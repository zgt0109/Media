class Huodong::PanoramagramsController < ApplicationController
	before_filter :require_wx_mp_user
	before_filter :find_panoramagram, only: [ :edit, :update, :destroy, :item_activity, :item_activity_create, :item_activity_update ]
	
	def index
    @activity = current_user.activities.where(activity_type_id:74, wx_mp_user_id:current_user.wx_mp_user.id, status:1, activityable_type: nil).first_or_initialize
	end

	def list
		@panoramagrams = current_user.panoramagrams.normal.order(:sort).page(params[:page])
	end

	def new
		@panoramagram = current_user.panoramagrams.new
		render :form
	end

	def edit
		@item_urls = @panoramagram.items.order("sort DESC").map(&:pic_url).join(',')
		@item_ids = @panoramagram.items.order("sort DESC").pluck(:id).join(',')
		render :form
	end

	def show
		FansGame.pluck(:id).each{|id| @activity.activities_fans_games.where(fans_game_id: id).first_or_create }
		@fans_games = FansGame.show.latest
		@ids = @activity.activities_fans_games.turn_up.pluck(:fans_game_id)
	end

	def create
		@panoramagram = current_user.panoramagrams.new(params[:panoramagram])
		if @panoramagram.save
			redirect_to list_panoramagrams_path, notice: "保存成功"
		else
			render_with_alert :form, "保存失败，#{@panoramagram.errors.full_messages.first}"
		end
	end

	def update
		if @panoramagram.update_attributes(params[:panoramagram])
			redirect_to list_panoramagrams_path, notice: "保存成功"
		else
			render_with_alert :form, "保存失败，#{@panoramagram.errors.full_messages.first}"
		end
	end

	def destroy
    @panoramagram.deleted!
    @panoramagram.activity.deleted! if @panoramagram.activity
    flash[:notice] = "保存成功"
    render js: "location.reload();"
	end

	def item_activity
		@activity = @panoramagram.activity || @panoramagram.build_activity(activity_type_id:74)
	end

	def item_activity_create
		@activity = @panoramagram.build_activity(params[:activity])
		@activity.supplier_id = current_user.id
		@activity.wx_mp_user_id = current_user.wx_mp_user.id
		@activity.activity_type_id = 74
		@activity.status = 1
		if @activity.save
			redirect_to item_activity_panoramagram_path, notice: "保存成功"
		else
			render_with_alert :item_activity, "保存失败，#{@activity.errors.full_messages.first}"
		end
	end

	def item_activity_update
		@activity = @panoramagram.activity
		if @activity.update_attributes(params[:activity])
			redirect_to item_activity_panoramagram_path, notice: "保存成功"
		else
			render_with_alert :item_activity, "保存失败，#{@activity.errors.full_messages.first}"
		end
	end

	private
    def find_panoramagram
    	@panoramagram = current_user.panoramagrams.where(id: params[:id]).first
    end
end