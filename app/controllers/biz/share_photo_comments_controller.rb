class Biz::SharePhotoCommentsController < ApplicationController
  before_filter :find_share_photo, only: [:index, :destroy]

  def index
    #@share_photo_comments =
    @search = @share_photo.share_photo_comments.search(params[:search])
    @share_photo_comments = @search.page(params[:page]).per(20)
  end

  def destroy
    @comment = @share_photo.share_photo_comments.where(id: params[:id]).first
    return redirect_to :back, notice: "数据错误" unless @comment
    if @comment.destroy
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to :back
  end

  private

  def find_share_photo
    @share_photo = current_user.share_photos.where(id: params[:share_photo_id]).first
  end

end
