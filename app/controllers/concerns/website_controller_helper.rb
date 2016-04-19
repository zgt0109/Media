module WebsiteControllerHelper
  def likes_comments_partial(params)
    like_params = { site_id: params.site_id, user_id: @user.try(:id), likeable_id: params.id, likeable_type: params.class.to_s }
    @like = Like.where(like_params).first
    unless @like
      @like = Like.new(like_params)
    end
    params.increment!(:view_count)
    comment_params = { site_id: params.site_id, commentable_id: params.id, commentable_type: params.class.to_s, commenter_id: @user.try(:id), commenter_type: @user.class.to_s }
    @comment = Comment.new(comment_params)
    @comments = params.comments
  end
end
