class Mobile::WebsiteArticlesController < Mobile::BaseController
  # skip_filter :load_data#, :auth
  include LikeableCommentable
  before_filter :find_website
  before_filter :set_categories, only: [:index, :show, :tags]
  before_filter :set_articles

  layout 'mobile/website_articles'

  def index
    #@website.website_articles.send('as_article').order('sort DESC').includes(:taggings).where('taggings.tag_id = 46 and website_articles.website_article_category_id = 5')
    #@website.website_articles.send('as_article').order('sort DESC').search({website_article_category_id_eq: 5, taggings_tag_id_eq: 46}).page(1)
    @articles = @search.page(params[:page])#.per(1)
  end

  def show
    @articles = @search.relation
    @article = @articles.where(id: params[:id]).first
    return redirect_to mobile_website_articles_url(site_id: @site.id, article_type: params[:article_type]) unless @article
    index = @articles.to_a.index(@article)
    @prev_article = @articles[index - 1] if index - 1 >= 0
    @next_article = @articles[index + 1] if @articles[index + 1]
    likes_comments_partial(@article, @user)
  end

  def tags
    tags_data = !@category ? [] : @category.root.tags.order('position DESC').limit(3).collect do |t|
      t.attributes.slice('id', 'name').merge!(children: t.children.collect{|tc| tc.attributes.slice('id', 'name')})
    end
    render json: {result: "success", data: tags_data}
  end

  private

  def find_website
    @website = @site.website

    @website_setting = @website.website_setting ||= @website.create_default_setting
    @site = @website.site
    return render text: '微官网不存在' unless @website
  rescue => error
    return render text: "出错了：#{error.message}"
  end

  def set_categories
    @categories = @website.categories.send(params[:article_type].presence || "as_article")
    @category = @categories.where(id: params[:category_id]).first
  end

  def set_articles
    @search = @website.website_articles.categorized(@category).visible.send(params[:article_type]).order("is_top DESC, sort #{@website_setting.send("#{params[:article_type].presence || 'as_article'}_sort")}").search(params[:search]) rescue WebsiteArticle.none.search
  end

end
