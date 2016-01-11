class Mobile::SharePhotosController < Mobile::BaseController
  layout 'mobile/share_photo'
  before_filter :block_non_wx_browser, :find_share_photo

  def show
    @share_photo_comment = @share_photo.share_photo_comments.new
  end

  def like
    @share_photo_like = @share_photo.share_photo_likes.new(site_id: @site.id, user_id: session[:user_id])
    unless @share_photo.share_photo_likes.where(user_id: session[:user_id]).first.present?
      @share_photo_like.save
      render :inline => "true"
    else
      render nothing: true
    end
  end

  private

  def find_share_photo
    #@user = User.find(session[:user_id])
    @share_photo = @site.share_photos.find(params[:id])
  end
end

