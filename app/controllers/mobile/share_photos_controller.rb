class Mobile::SharePhotosController < Mobile::BaseController
  layout 'mobile/share_photo'
  before_filter :block_non_wx_browser, :find_share_photo

  def show
    @share_photo_comment = @share_photo.share_photo_comments.new
  end

  def like
    @share_photo_like = @share_photo.share_photo_likes.new(supplier_id: @supplier.id, wx_mp_user_id: @share_photo.wx_mp_user_id, wx_user_id: session[:wx_user_id])
    unless @share_photo.share_photo_likes.where(wx_user_id: session[:wx_user_id]).first.present?
      @share_photo_like.save
      render :inline => "true"
    else
      render nothing: true
    end
  end

  private

  def find_share_photo
    #@wx_user = WxUser.find(session[:wx_user_id])
    @share_photo = @supplier.share_photos.find(params[:id])
  end
end

