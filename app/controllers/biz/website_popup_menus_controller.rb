class Biz::WebsitePopupMenusController < ApplicationController
  before_filter :set_website
  before_filter :set_website_popup_menu, only: [:show, :edit, :update, :destroy]

  def index
    @nav_type = params[:nav_type].present? ? params[:nav_type].to_i : [1, 2]
    @menus = @website.website_popup_menus.where(nav_type: @nav_type).order(:sort)
    @menu_sorts = @menus.map{|m| m.sort}
    @menu_sorts = 1..(@menu_sorts.max.to_i + 1)
    menu = @menus.first

    if @nav_type.is_a?(Array)
      @website_setting = @website.website_setting ||= @website.create_default_setting
      @unable_edit_home_menu = WebsiteSetting::UNABLE_CUSTOM_NAV_TEMPLATE_IDS.include?(@website_setting.index_nav_template_id)
      @unable_edit_inside_menu = WebsiteSetting::UNABLE_CUSTOM_NAV_TEMPLATE_IDS.include?(@website_setting.nav_template_id)
    end
  end

  def new
    @website_popup_menu = @website.website_popup_menus.new(menu_type: WebsitePopupMenu::ACTIVITY, nav_type: params[:nav_type].to_i)
    @website_popup_menu.sort = @website.website_popup_menus.where(nav_type: params[:nav_type].to_i).order(:sort).try(:last).try(:sort).to_i + 1
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def create
    @website_popup_menu = @website.website_popup_menus.new(params[:website_popup_menu])
    if @website_popup_menu.save
      flash[:notice] = "添加成功"
      url = @website_popup_menu.nav_type.to_i == 0 ? website_popup_menus_path(nav_type: 0) : website_popup_menus_path(target: "#tab-#{@website_popup_menu.nav_type}")
      render inline: "<script>window.parent.location.href = '#{url}';</script>"
    else
      flash[:alert] = "添加失败"
      render action: 'new', layout: 'application_pop'
    end
	end
	
	def update
    if @website_popup_menu.update_attributes(params[:website_popup_menu])
      flash[:notice] = "保存成功"
      url = @website_popup_menu.nav_type.to_i == 0 ? website_popup_menus_path(nav_type: 0) : website_popup_menus_path(target: "#tab-#{@website_popup_menu.nav_type}")
      render inline: "<script>window.parent.location.href = '#{url}';</script>"
    else
      flash[:alert] = "保存失败"
      render action: 'edit', layout: 'application_pop'
    end
	end

  def destroy
    if @website_popup_menu.destroy
      url = @website_popup_menu.nav_type.to_i == 0 ? website_popup_menus_path(nav_type: 0) : website_popup_menus_path(target: "#tab-#{@website_popup_menu.nav_type}")
      redirect_to "#{url}", notice: '删除成功'
    else
      redirect_to "#{url}", notice: '删除失败'
    end
  end

  def copy
    website_setting = @website.website_setting
    if WebsiteSetting::UNABLE_CUSTOM_NAV_TEMPLATE_IDS.include?(website_setting.index_nav_template_id)
      return redirect_to :back, notice: '当前首页导航模版不支持自定义，不能复制数据'
    elsif WebsiteSetting::UNABLE_CUSTOM_NAV_TEMPLATE_IDS.include?(website_setting.nav_template_id)
      return redirect_to :back, notice: '当前内页导航模版不支持自定义，不能复制数据'
    else
      return redirect_to :back, notice: "当前#{WebsitePopupMenu::nav_type_options.select{|f| f.last == params[:from].to_i}.flatten.first}模版没有数据" if @website.website_popup_menus.where(nav_type: params[:from]).count == 0
      @website.copy_website_popup_menus(params[:from], params[:end])
      redirect_to :back, notice: '复制数据成功'
    end
  end

  def update_menu_sort
    sort = params[:sort].try(:to_i) || 1
    menus = @website.website_popup_menus.where(nav_type: params[:nav_type].to_i).order(:sort)
    menus.each do |menu|
      if menu.id == params[:menu_id].to_i
        menu.update_attribute(:sort, sort)
      elsif menu.sort >= sort
        menu.update_attribute(:sort, menu.sort + 1)
      end
    end
    render :text => params.inspect
  end

  private
  
  def set_website
    @website = current_site.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end

  def set_website_popup_menu
    @website_popup_menu = @website.website_popup_menus.where(id: params[:id]).first
    return redirect_to websites_path, alert: '菜单不存在或已删除' unless @website_popup_menu
  end

end
