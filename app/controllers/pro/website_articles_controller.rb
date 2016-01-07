class Pro::WebsiteArticlesController < WebsiteShared::WebsiteArticlesController
  before_filter :set_life_website

  
  private
  def find_website_article
    set_life_website
    @website_article = @website.website_articles.find params[:id]
  end
end
