class Mobile::AlbumsController < Mobile::BaseController
  skip_before_filter :auth, :authorize
  before_filter :authorize, only: [:comments, :create_comment]
  before_filter :block_non_wx_browser
  before_filter :find_photo, only: [:show, :comments, :create_comment, :load_more_comments]
  before_filter :find_album, only: [:list, :load_more_photos]
  
  layout 'mobile/albums'

  def index
    @activity = Activity.find(params[:aid])
    @share_image = @activity.albums.show.first.try(:photos).try(:first).present? ? @activity.albums.show.first.try(:photos).try(:first).try(:img_url) : (@activity.qiniu_pic_url.present? ? @activity.qiniu_pic_url :  @activity.default_pic_url)
    # render layout: "mobile/albums_old"
  end

  def list    
    @share_image = @album.photos.first.try(:img_url)
    render "list_#{@album.browsing_way}"
  end

  def show
    photo_ids = @photo.album.photos.pluck(:id).insert(0,params[:id].to_i).uniq.join(",")
    @photos = @photo.album.photos.order("find_in_set(id, '#{photo_ids}')")
  end

  def comments
    @comments = @photo.comments.latest.page(1)
    @share_image = @photo.img_url
    @comment = Comment.new
    respond_to do |format|
      format.html
      format.js
    end
  rescue
    return render text: '请求页面不存在'
  end

  def create_comment
    @comment = @photo.comments.new(params[:comment].merge(commenter_id: session[:user_id], commenter_type: 'User', site_id: @site.id))
    #flag = Comment.where("commenter_id = ? and commentable_type =? and commenter_type = ? and commentable_id = ? and created_at >= ?", session[:user_id], "AlbumPhoto", "WxUser", @photo.id, Time.now.midnight).length > 0
    #if flag
    #  redirect_to :back, alert: "您今天已经发表过评论了！"
    if @comment.save
      redirect_to comments_mobile_album_url(@site, @photo.id), notice: "评价成功！"
      # redirect_to comments_mobile_album_url(@site, @photo), notice: "评价成功！"
    else
      redirect_to :back, alert: "评价失败，#{@comment.errors.full_messages.first}"
    end
  end

  def load_more_photos
    @photos = @album.photos.page(params[:page]).collect{|p| {link_to: mobile_album_url(p, site_id: p.album.site_id), img_url: p.img_url} }
    render json: {photos: @photos}
  end

  def load_more_comments
    @comments = @photo.comments.latest.page(params[:page]).collect{|c| c.attributes.slice('nickname', 'comment').merge!(created_at: c.created_at.to_date.to_s) }
    render json: {comments: @comments}
  end

  private
    def find_photo
      @photo = AlbumPhoto.where(id: params[:id]).first
      return render_404 if @photo.nil?
    end

    def find_album
      @album = Album.where(id: params[:id]).first
      return render_404 if @album.nil?
    end

end