module App
  class BusinessCirclesController < BaseController
    include WxReplyMessage
    layout "app/business_circle"

    def index
      @website = Website.find(params[:id])
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures.sorted
    end

    def show
      @website_menu = WebsiteMenu.find(params[:id])
      @website = Website.find(@website_menu.website_id)
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @articles = @website.website_articles.recommend.order(:sort)
    rescue
      return render text: '请求页面不存在'
    end

    def page
      if params[:popup_menu_id]
        @website_popup_menu = WebsitePopupMenu.find(params[:popup_menu_id])
        @website = @website_popup_menu.website
      else
        @website_menu = WebsiteMenu.find(params[:id])
        @website = @website_menu.website
      end
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
    rescue
      return render text: '请求页面不存在'
    end

    def detail
      @article = WebsiteArticle.find(params[:id])
      @website = @article.website
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
      @comments = @article.website_comments.order('created_at desc').page(params[:page])
      @share_image = @article.pic_key.present? ? @article.pic_key.to_s : Nokogiri::HTML(@article.content.to_s).at_css("img").to_h["src"]
      @share_desc = Nokogiri::HTML(@article.content.to_s).content.gsub(/[\p{Punctuation}\p{Symbol}]|\r\n|\ +/, "").first(100)
      respond_to do |format|
        format.html
        format.js
      end
    rescue
      return render text: '请求页面不存在'
    end

    def comment
      @comment = WebsiteComment.new
      @article = WebsiteArticle.find(params[:id])
      @comments = @article.website_comments.order('created_at desc').page(params[:page])
      @website = @article.website
      @website_popup_menus =  @website.website_popup_menus.order(:sort)
      @website_pictures = @website.website_pictures
    end

    def create_comment
      @article = WebsiteArticle.find(params[:website_article_id])
      @comment = @article.website_comments.new(params[:website_comment])
      if @comment.save
        redirect_to detail_app_business_circle_path(@article), :notice => "评论成功！"
      else
        flash[:notice] = "评论失败！"
        render :acton => :comment
      end
    end

  end
end
