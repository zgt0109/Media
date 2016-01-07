module App
  class LivesController < BaseController
    layout 'app/life'
    #before_filter :find_life, :except=> [:page]

    def index
      @website = Website.find(params[:id])
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @share_image = @website.activity.try(:pic_display_url)
    rescue
      render text: '页面不存在'
    end

    def show
      @website_menu = WebsiteMenu.find(params[:id])
      @website = Website.find(@website_menu.website_id)
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @articles = @website.website_articles.recommend.order(:sort)#WebsiteArticle.where("is_recommend = ? and webiste_type = ? ", 1, 2).order("created_at desc")
    end

    def page
      if params[:popup_menu_id]
        @website_popup_menu = WebsitePopupMenu.find(params[:popup_menu_id])
        @website = @website_popup_menu.website
      else
        @website_menu = WebsiteMenu.find(params[:id])
        @website = @website_menu.website
        #@website_articles = @website_menu.website_articles
      end
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      # @website_pictures = @website.website_pictures
    end

    def detail
      @article = WebsiteArticle.find(params[:id])
     # @website_menu = @article.website_menu
      @website = @article.website
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @comments = @article.website_comments.order('created_at desc')
    end

    def comment
      @comment = WebsiteComment.new
      @article = WebsiteArticle.find(params[:id])
      @comments = @article.website_comments.order('created_at desc')
      @website = @article.website
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
    end

    def create_comment
      @article = WebsiteArticle.find(params[:website_article_id])
      @comment = @article.website_comments.new(params[:website_comment])
      if @comment.save
        redirect_to detail_app_life_path(@article), :notice => "评论成功！"
      else
        flash[:notice] = "评论失败！"
        render :acton => :comment
      end
    end

    private

    def find_life
      #@website = Website.find(params[:id])
      # @website = @wx_mp_user.website
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
    end

  end
end
