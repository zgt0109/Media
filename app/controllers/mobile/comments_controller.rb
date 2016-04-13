class Mobile::CommentsController < Mobile::BaseController
  def index
    @comments = Comment.all
  end

  def create
    @comment = Comment.new(params[:comment])
    respond_to do |format|
      if @comment.save
        format.html { redirect_to :back }
        format.js
      else
        format.js
      end
    end
  end
  
end
