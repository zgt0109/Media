class Biz::AlbumPhotosController < ApplicationController
  layout 'application_gm'
  skip_before_filter :verify_authenticity_token, only: [:upload]
  before_filter :find_album
  before_filter :check_activity


  def index
    @photos = @album.photos.order('id ASC').page(params[:page]).per(9)
    @photo  = AlbumPhoto.new
  end

  def create
    @photo = @album.photos.build(name: params[:name])
    if @photo.save
      render json: {}
    end
  end

  def save_qiniu_keys
    @photo = AlbumPhoto.new
    @photo.album_id = @album.id
    @photo.name = params[:name]
    @photo.qiniu_pic_key = params[:qiniu_pic_key]
    @photo.save
    render :partial => "biz/albums/photo", :locals => {photo: @photo, album_id: @album.id}
  end

  def show
    @album_id, @photo_id = params[:album_id], params[:id]
    @album = Album.find_by_id(@album_id)
    @photo = AlbumPhoto.find_by_id(@photo_id)
    #render :text => @photo.inspect
    render layout: 'application_pop'
  end

  def upload
      @photo = @album.photos.new
      @photo.pic = params[:pic]
      @album.touch if @photo.save
      @photos = @album.photos.order('created_at desc')
      respond_to do |format|
        format.js {}
        format.html { render nothing: true }
      end
  end

  def update
    @photo = @album.photos.find params[:id]
    @photo.update_attributes(name: params[:album_photo][:name])
    redirect_to "/albums/#{params[:album_id]}/edit"
  end

  def destroy
    photo = @album.photos.find params[:id]
    photo.destroy
    render json: {}
  end

  def is_cover
    @album.update_attributes(cover_id: params[:id].to_i)
    render js: "$('#photo_#{params[:id]}').addClass('on').siblings().removeClass('on');"
  end

  def find_album
    @album = current_user.albums.find params[:album_id]
  end

  def check_activity
    return redirect_to activity_albums_path, notice: '请先填写活动信息' unless current_user.album_activity
  end

end
