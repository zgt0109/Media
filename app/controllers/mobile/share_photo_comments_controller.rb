class Mobile::SharePhotoCommentsController < Mobile::BaseController
  layout 'mobile/share_photo'
  before_filter :block_non_wx_browser, :find_photo
  
  def index
    @share_photo_comments = @share_photo.share_photo_comments
    respond_to do |format|
      format.js { render layout: false }
    end    
  end
  
  def create
    @share_photo_comment = @share_photo.share_photo_comments.new(params[:share_photo_comment])
    if @share_photo_comment.save
      redirect_to mobile_share_photo_path(site_id: @site.id, id: @share_photo.id), notice: "评论成功"
    else
      render :back, notice: "评论失败"
    end
  end

  private
  
  def find_photo
    @share_photo = @site.share_photos.find(params[:share_photo_id])
  end
end

