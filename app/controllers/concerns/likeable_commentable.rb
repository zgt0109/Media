module LikeableCommentable
  def likes_comments_partial(resource, user)
    resource.increment!(:view_count)

    like_params = {
      site_id: (resource.is_a?(WebsiteMenu) ? resource.website.site_id : resource.site_id),
      user_id: user.try(:id),
      likeable_id: resource.id,
      likeable_type: resource.class.to_s
    }
    @like = Like.where(like_params).first
    @like = Like.new(like_params) unless @like

    comment_params = {
      site_id: (resource.is_a?(WebsiteMenu) ? resource.website.site_id : resource.site_id),
      commentable_id: resource.id,
      commentable_type: resource.class.to_s,
      commenter_id: user.try(:id),
      commenter_type: user.try(:class).to_s
    }
    @comment = Comment.new(comment_params)
    @comments = resource.comments
  end
end
