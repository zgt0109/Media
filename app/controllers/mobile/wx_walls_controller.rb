class Mobile::WxWallsController < Mobile::BaseController
  skip_before_filter :auth, :authorize
  before_filter :block_non_wx_browser

  def show
  	@supplier = Supplier.find params[:supplier_id]
  	@wx_wall = @supplier.wx_walls.find params[:id]
    @is_image = params[:msg_type] == 'image'
    @pictures = @wx_wall.qiniu_pictures
    @messages = @wx_wall.wx_wall_messages.normal.recent.limit(20).includes(:wx_wall_user)
    @messages = @messages.where("id > ?", params[:message_id]) if params[:message_id]
  end

end
