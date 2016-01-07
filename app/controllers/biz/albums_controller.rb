class Biz::AlbumsController < ApplicationController

  before_filter :find_album_activity
  before_filter :set_activity_url, only: [:activity, :create_activity, :update_activity, :destroy_comment]
  before_filter :check_activity, except: [:activity, :create_activity, :destroy_comment]
  before_filter :restrict_trial_supplier, except: [:index, :activity, :destroy_comment]
  before_filter :require_wx_mp_user, only: [:activity, :index, :destroy_comment]
  before_filter :set_album, only: [:edit, :update, :destroy, :sort, :visible, :delete_photo]
  def activity
  end

  def create_activity
    @activity = current_user.wx_mp_user.build_album_activity params[:activity]
    if @activity.save
      redirect_to activity_albums_path, notice: '保存成功'
    else
      render :activity, alert: '保存失败'
    end
  end

  def extend_format
    return unless @activity
    extent_attrs = params[:activity][:extend].to_h
    %w(allow_show_vote_percent allow_show_vote_count allow_show_user_tel album_watermark_img tel show_watermark).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", extent_attrs[method_name])
    end

    %i(allow_repeat_apply closing_note).each do |method_name|
      @activity.extend.send("#{method_name.to_s}=", params[method_name])
    end
  end

  def update_activity
    @activity = current_user.album_activity
    extend_format
    @activities = current_user.activities.show.where(keyword: params[:activity][:keyword])
    if @activity.update_attributes params[:activity]
      redirect_to activity_albums_path, notice: '保存成功'
    else
      flash[:alert] = '保存失败'
      render :activity
    end
  end

  def index
    @search = current_user.albums.order('albums.sort, albums.updated_at DESC').search(params[:search])
    @album_first_id = @search.first.try(:id)
    @album_last_id = @search.last.try(:id)
    @albums = @search.page(params[:page])
  end

  def new
    @album = Album.new
    @photo  = AlbumPhoto.new    
    render "edit"
  end

  def edit
    @photos = @album.photos.order('created_at desc')
    @photo  = AlbumPhoto.new
  end

  def create
    @album  = current_user.albums.build(params[:album].merge wx_mp_user: current_user.wx_mp_user, activity: @activity)
    if @album.save
      # params[:redirect_to_on_pop_close] = "/albums" # 这样关闭pop弹窗以后会自动刷新相册列表
      flash[:notice] = '保存成功'
      # redirect_to edit_album_path(@album)
    else
      message = @album.error_messages.join("\n")
      flash[:notice] = "保存失败: #{message}"
    end
    render "edit"
  end

  def update
    @photos = @album.photos.order('created_at desc')
    if @album.update_attributes(params[:album])
      flash[:notice] = '保存成功'
      redirect_to albums_path
    else
      message = @album.error_messages.join("\n")
      flash[:notice] = "保存失败: #{message}"
      render :edit, layout: 'application_pop'
    end
  end

  def destroy
    @album.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  def sort
    albums = current_user.albums.order('albums.sort, albums.updated_at DESC')
    albums.each_with_index{|album, index| album.sort = index + 1}
    from_album = albums.select{|f| f.id == params[:from_id].to_i}.first
    index = albums.index(@album)
    sort_index = albums.index(from_album)
    albums[index].sort = albums[sort_index].sort
    #靠后排
    if sort_index > index
      albums.each_with_index{|album, i| album.sort = album.sort - 1 if i <= sort_index && i > index}
    #靠前排
    elsif sort_index < index
      albums.each_with_index{|album, i| album.sort = album.sort + 1 if i >= sort_index && i < index}
    end
    albums.each{|album| album.update_column('sort', album.sort) if album.sort_changed?}
    redirect_to :back, notice: '操作成功'
  rescue => error
    redirect_to :back, alert: '操作失败'
  end

  def visible
    @album.update_visible!
    render json: {type: 'success', info: '操作成功'}
  rescue => error
    render json: {type: 'warning', info: '操作失败'}
  end


  def comments
    album = current_user.albums.where(id: params[:id]).first if params[:id].present?
    ids = album.photos.collect(&:id) if album
    if ids.present?
      @search   = Comment.where(commentable_type: 'AlbumPhoto', supplier_id: current_user.id, commentable_id: ids).order('created_at DESC').search(params[:search])
    else
      @search   = Comment.where(commentable_type: 'AlbumPhoto', supplier_id: current_user.id).order('created_at DESC').search(params[:search])
    end
    @comments = @search.page(params[:page])
  end

  def destroy_comment
    comment = Comment.where(commentable_type: 'AlbumPhoto', supplier_id: current_user.id).find params[:comment_id]
    id = comment.commentable.try(:album).try(:id)
    if comment.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, notice: '删除失败'
    end
    #render js: "$('#row-#{comment.id}').remove(); showTip('success', '删除成功');"
  end

  def delete_photo
    photo_ids = params[:photo_ids].to_s.split(",")
    @album.photos.where(id: photo_ids).destroy_all if photo_ids.present?
    render json: {type: 'success', info: '操作成功'}
  end

  private
  def find_album_activity
    @activity = current_user.album_activity || current_user.wx_mp_user.build_album_activity
  end

  def set_activity_url
    @activity_url = @activity.new_record? ? create_activity_albums_path : update_activity_albums_path(@activity)
  end

  def check_activity
    return redirect_to activity_albums_path, notice: '请先填写活动信息' unless current_user.album_activity
  end

  def set_album
    @album = current_user.albums.where(id: params[:id]).first
    return redirect_to albums_path, alert: '相册不存在或已删除' unless @album
  end

end
