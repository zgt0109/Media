class Mobile::CommentsController < Mobile::BaseController
  def create
    @comment = Comment.new(params[:comment])
    respond_to do |format|
      if @comment.save
        @comments = @comment.commentable.comments
        format.html { redirect_to :back }
        format.js
      else
        format.js
      end
    end
  end

end
