class SitesController < ApplicationController
  before_filter :load_site, only: [:show, :update]

  def index
    @partialLeftNav = "/layouts/partialLeftSys"
    @sites = current_user.sites
    render layout: 'application'
  end

  def new
    @site = current_user.sites.new
    render layout: 'application_pop'
  end

  def create
    @site = current_user.sites.new(params[:site])

    if @site.save
      flash[:notice] = '新增成功'
      render inline: "<script>window.parent.location.href = '#{sites_url}';</script>"
    else
      flash[:alert] = "新增失败"
      render action: 'new', layout: 'application_pop'
    end
  end

  def show
    render layout: 'application_pop'
  end

  def update
    if @site.update_attributes(params[:site])
      flash[:notice] = '更新成功'
      render inline: "<script>window.parent.location.href = '#{sites_url}';</script>"
    else
      flash[:alert] = "更新失败"
      render action: 'show', layout: 'application_pop'
    end
  end

  def switch
    @partialLeftNav = "/layouts/partialLeftSys"
    session[:pc_site_id] = params[:site_id] if params[:site_id].to_i > 1
    redirect_to :back
  end

  def copyright
    # @ret = 1 #默认 2. 自定义 3. 不显示
    site_copyright = current_site.copyright
    # @ret = 1
    site_copyright = SiteCopyright.find_by_id(current_site.site_copyright)
    if !current_site.show_copyright?
      @ret = 3
    elsif site_copyright && !site_copyright.is_default?
      @ret = 2
    else
      @ret = 1
    end
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def update_copyright
    ret = params[:status].to_i
    site_copyright = current_site.site_copyright
    if ret == 1 #默认
      current_site.site_copyright_id = SiteCopyright.default_footer.id #使用默认 footer
      current_site.show_copyright = true
    elsif ret == 2
      content = params[:content]
      link = params[:link]
      site_copyright = current_site.site_copyrights.where(is_default: false).first
      if site_copyright && !site_copyright.is_default? #不用新建
        site_copyright.footer_content = content
        site_copyright.footer_link = link
      else #要新建
        site_copyright = SiteCopyright.create(footer_content: content, footer_link: link, site_id: current_site.id)
      end
      current_site.show_copyright = true
      current_site.site_copyright_id = site_copyright.id
    elsif ret == 3
      current_site.show_copyright = false
      current_site.site_copyright_id = site_copyright.id if site_copyright
    end

    if current_site && site_copyright && site_copyright.save! && current_site.save!
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: '更新失败'
    end
  end

  private
    def load_site
      @site = current_user.sites.find(params[:id])
    end
end
