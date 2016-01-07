class Biz::SharePhotosController < ApplicationController

  def index
    @search = current_user.share_photos.search(params[:search])
    @share_photos = @search.page(params[:page]).per(10)
  end

  def destroy
    @share_photo = current_user.share_photos.where(id: params[:id]).first
    return redirect_to :back, notice: "数据错误" unless @share_photo
    if @share_photo.destroy
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to :back
  end

end
