class Biz::GreetsController < ApplicationController  

  before_filter :find_greet_activity
  before_filter :set_activity_url, only: [:activity, :create_activity, :update_activity]
  before_filter :check_activity, except: [:activity, :create_activity]
  # before_filter :require_wx_mp_user, only: [:activity, :index]

  def activity
  end

  def create_activity
    @activity = current_site.build_greet_activity params[:activity]
    if @activity.save
      redirect_to activity_greets_path, notice: '保存成功'
    else
      render_with_alert :activity, "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
  end

  #顶部图片更新
  def update_activity
    @activity = current_site.greet_activity
    @activity = current_site.build_greet_activity params[:activity]
    if @activity.update_attributes params[:activity]
      redirect_to activity_greets_path, notice: '保存成功'
    else
      render_with_alert :activity, "保存失败：#{@activity.errors.full_messages.join('，')}"
    end
  end

  def index
    @search = current_site.greets.order('id ASC').search(params[:search])
    @greet = @search.page(params[:page])
  end

  def new
    @greet = Greet.new
    # @photo  = AlbumPhoto.new
    render layout: 'application_pop'
  end

  def edit
    @greet = current_site.greets.find params[:id]
    # @photos = @album.photos.order('id ASC')
    # @photo  = AlbumPhoto.new
    render layout: 'application_pop'
  end

  def create
    @greet  = current_site.greets.build(params[:greet].merge activity: @activity)
    if @greet.save
      redirect_to greet_cards_path, notice: '保存成功'
    else
      message = @greet.error_messages.join("\n")
      flash[:notice] = "保存失败: #{message}"
      render :new, layout: 'application_pop'
    end
  end

  def update
    @greet = current_site.greets.find params[:id]
    @greet.update_attributes(params[:greet])
    redirect_to greet_cards_url, notice: "更新成功"
  end

  def destroy
    # album = current_site.albums.find params[:id]
    # album.destroy
    # respond_to do |format|
    #   format.html { redirect_to :back, notice: '删除成功' }
    #   format.json { head :no_content }
    # end
  end

  private

    def find_greet_activity
      @activity = current_site.greet_activity || current_site.build_greet_activity
    end

    def set_activity_url
      @activity_url = @activity.new_record? ? create_activity_greets_path : update_activity_greets_path
    end

    def check_activity
      return redirect_to activity_greets_path, notice: '请先填写活动信息' unless current_site.greet_activity
    end

end
