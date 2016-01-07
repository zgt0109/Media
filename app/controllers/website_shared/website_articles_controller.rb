class WebsiteShared::WebsiteArticlesController < WebsiteShared::WebsiteBaseController
  
  before_filter :find_website_article, only: [:edit, :update, :destroy, :toggle_recommend]

  def index
    @website_articles = @website.website_articles.order("sort DESC").page(params[:page])
  end
  
  def new
    @website_article = @website.website_articles.build
    render layout: 'application_pop'
  end
  
  def edit
    render layout: 'application_pop'
  end
  
  def create
		@website_article = @website.website_articles.new(params[:website_article])
		if @website_article.save
      flash.now[:notice] = '保存成功'
      render "pro/website_articles/create", layout: false
    else
      flash.now[:alert] = @website_article.errors.full_messages.first
      render :new, layout: 'application_pop'
    end
	end
	
	def update
		if @website_article.update_attributes(params[:website_article])
      flash.now[:notice] = '保存成功'
      render "pro/website_articles/update", layout: false
    else
      redirect_to :back, notice: '更新失败'
    end
	end

  def destroy
    @website_article.destroy
    render js: "showTip('success', '删除成功'); $('#article-row-#{@website_article.id}').remove();"
  end

  def toggle_recommend
    @website_article.update_attributes!(is_recommend: !@website_article.is_recommend)
    render js: "showTip('success', '设置成功');"
  end

end
