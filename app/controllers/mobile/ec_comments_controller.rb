class Mobile::EcCommentsController < Mobile::BaseController
  layout "mobile/ec"

  before_filter :set_item_and_comments, :except => [:create]

  def index

  end

  def new
    @comment = EcComment.new
  end

  def create
    @item = EcItem.find(params[:id])
    @comment = @item.ec_comments.new(params[:ec_comment])
    if @comment.save
      redirect_to new_mobile_ec_comment_path(site_id: @site.id,:id => @item.id), :notice =>  "评论成功"
    else
      render :action => :new, :notice => "评论失败"
    end
  end

  def set_item_and_comments
    @item = EcItem.find(params[:id])
    @comments = @item.ec_comments.order("created_at desc")
  end


end
