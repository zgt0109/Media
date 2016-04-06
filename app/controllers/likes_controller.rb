class LikesController < ApplicationController
  def create
    @like = Like.create(like_params)
    @like.save
    redirect_to mobile_website_article_likes_path
  end

  def destroy
    @like.destroy
    redirect_to mobile_website_article_like_path
  end

  private
    def like_params
      params.require(:like).permit(:site_id, :user_id)
    end
end
