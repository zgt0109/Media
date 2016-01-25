class Biz::WebsitesController < ApplicationController
  before_filter :find_website, except: [:create_initial_data]

  def index
    #pp request.domain
    #pp request.host_with_port
    @website = current_site.create_activity_for_website.website unless @website
    @activity = @website.activity
  end

  def update
    respond_to do |format|
      if @website.update_attributes(params[:website])
        format.html { redirect_to :back, notice: '保存成功' }
        format.js {}
      else
        format.html { redirect_to :back, notice: '保存失败' }
        format.js {}
      end
    end
  end

  def destroy
    if @website.clear_menus!
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def open_popup_menu
    if @website.open_popup_menu!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def close_popup_menu
    if @website.close_popup_menu!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def delete_home_cover_pic
    @website.home_cover_pic.remove!
    if @website.save
      redirect_to :back
    else
      redirect_to :back, notice: '操作失败'
    end
  end

  def qrcode
    @website_domain = @website.domain
    if params[:menu_id]
      @menu = params[:menu_id].to_i > 0 && WebsiteMenu.where(:id => params[:menu_id]).first
      return render :layout => nil, :action => "qrcode_by_menu"
    end
  end

  def domain
  end

  def custom_domain
    message = {type: 'error'}
    only_domain = params[:value]
    if only_domain.empty?
      message[:info] = '个性化域名不能为空!'
    elsif only_domain =~ /^\d+$/
      message[:info] = '个性化域名不能全为数字!'
    elsif only_domain =~ /^[A-Za-z][\w]*\.?[\w]*[\w]$/
      if Website.where(:domain => only_domain).count > 0
        message[:info] = '个性化域名已存在!'
      else
        only_domain.chop! if only_domain.end_with?"/"
        @website.update_attributes(:domain => only_domain);
        self.update_piwik_domain_status(@website, only_domain)
        message[:type] = 'success'
        message[:info] = '个性化域名设置成功!'
        message[:img] = @website.preview
      end
    else
      message[:info] = '个性化域名只能包含数字、字母、下划线和一个点（.）!'
    end
    render json: message
  end

  def download
    send_data @website.download, :disposition => 'attachment', :filename=>"winwemedia-#{@website.custom_domain}.jpg"
  end

  def update_piwik_domain_status(website, domain)
    site = website.site
    if site
      if site.piwik_domain_status == 0 &&  domain.present?
        site.update_attribute(:piwik_domain_status, 1)
      end
    end
  rescue Exception => e
    Rails.logger.info "Biz::WebsitesController#update_piwik_domain_status ERROR: #{e}"
  end

  def pictures
    render text: @website.website_pictures.count
  end

  def help
  end

  def create_initial_data
    activity = current_site.create_activity_for_website
    activity.website.create_default_data if params[:is_initialize] == '1'
    return render text: '1'
  rescue
    return render text: '0'
  end

  def menus_sort
    @website.send(params[:type].to_sym)
    redirect_to website_menus_path, notice: '操作成功'
  end

  private

  def find_website
    @website = current_site.website
    return redirect_to websites_path, alert: '请先设置微官网' unless params[:action] == 'index' || @website
  end

end
