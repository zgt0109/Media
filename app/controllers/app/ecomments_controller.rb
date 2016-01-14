module App
  class EcommentsController < BaseController
     layout "app/ebusiness"

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
        redirect_to new_app_ecomment_url(:id => @item.id), :notice =>  "评论成功"
      else
        render :action => :new, :notice => "评论失败"
      end
    end

    def set_item_and_comments
      @item = EcItem.find(params[:id])
      @comments = @item.ec_comments.order("created_at desc")
    end

  end
end
