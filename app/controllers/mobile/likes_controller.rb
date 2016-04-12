class Mobile::LikesController < Mobile::BaseController
  def create
    @like = Like.new(params[:like])
    respond_to do |format|
      if @like.save
        format.html { redirect_to :back }
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    @like = Like.find(params[:id])
    @likeable = @like.likeable
    @like.destroy
    @like = Like.new(site_id: @site.id, user_id: @user.id, likeable_id: @likeable.id, likeable_type: "WebsiteArticle")
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
