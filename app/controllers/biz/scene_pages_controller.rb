class Biz::ScenePagesController < ApplicationController
  before_filter :fetch_activity
  before_filter :fetch_scene_html, only: [:save_html, :save_json, :pages_config]

  def index
  end

  def pages_config
    @scene_links = collect_scene_links
    if @scene_html.version.present?
      render "pages_config_#{@scene_html.version}"
    else
      render "pages_config"
    end
  end

  def save_html
    @scene_html.update_attributes(content: params[:page_html]) if params[:page_html].present?
    render json: {status: 'ok'}
  end

  def save_json
    @scene_html.update_attributes(content: params[:page_json]) if params[:page_json].present?
    render json: {status: 'ok'}
  end

  def edit
    @page =  Scene.find(params[:id])
  end

  def new
    @page =  Scene.new
  end

  def create
    @page = Scene.new(params[:scene])
    @page.save
    redirect_to scene_pages_path(activity_id: @page.activity_id), notice: '保存成功'
  end

  def update
    @page = Scene.find(params[:id])
    @page.update_attributes(params[:scene])
    redirect_to scene_pages_path(activity_id: @page.activity_id), notice: '保存成功'
  end

  def destroy
    @page =  Scene.find(params[:id])
    @page.destroy
    redirect_to :back, notice: "操作成功"
  end

  private
    def fetch_scene_html
      @activity.scene_html = SceneHtml.where(activity_id: @activity.id).first_or_create(version: 'v3.0.0', content: [].to_json)
      @scene_html = @activity.scene_html
    end

    def fetch_activity
      @activity = current_site.activities.scene.find(params[:activity_id])
    end

    def collect_scene_links
      activities = current_site.activities.show
      [
        {
          '微投票' => activities.vote.map{|e| {name: e.name, url: e.respond_mobile_url} },
        },
        {
          '微报名' => activities.enroll.map{|e| {name: e.name, url: e.respond_mobile_url} },
        },
        {
          '微调研' => activities.surveys.map{|e| {name: e.name, url: e.respond_mobile_url} },
        },
        {
          '微预定' => activities.reservation.map{|e| {name: e.name, url: e.respond_mobile_url} }
        }
      ]
    end
end
