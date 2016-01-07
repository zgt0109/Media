class NewsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  layout "home"

  # caches_page :index, :qa, :company, :show

  def index
    @html_class = "report"
    @title = "公司动态"
    params[:type] ||= "company"
    if params[:type] == "company"
      @news = News.company.order('created_at desc').select("id,title,short_content,pic").page(params[:page]).per(6) rescue []
    elsif params[:type] == "broadcast"
      @news = News.broadcast.order('created_at desc').select("id,title,short_content,pic").page(params[:page]).per(6) rescue []
    elsif params[:type] == "industry_news"
      @news = News.industry_news.order('created_at desc').select("id,title,short_content,pic").page(params[:page]).per(6) rescue []
    end

    respond_to do |format|
      format.html {}
      format.json do
        render json: {datalist: News.report_json(@news)}
      end
    end
  end

  def qa
    @title = "常见问题"
    if params[:display] == "dashboard"
      @news = News.qa.order('created_at desc').page(params[:page]).per(6)
    else
      @news = News.qa.order('created_at desc').page(params[:page]).per(15)
      return render 'more'
    end
    render 'index'
  end

  def company
    @html_class = "report"
    @title = "公司动态"
    if params[:display] == "dashboard"
      @news = News.company.order('created_at desc').select("id,title,short_content,pic").page(params[:page]).per(6) rescue []
      respond_to do |format|
        format.html {}
        format.json do
          render json: {datalist: News.report_json(@news)}
        end
      end
    else
      @news = News.company.order('created_at desc').page(params[:page]).per(15)
      return render 'more'
    end
    # render 'index'
  end

  def show
    @news = News.find(params[:id])
  end

end
