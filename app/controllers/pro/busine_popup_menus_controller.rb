class Pro::BusinePopupMenusController < WebsiteShared::WebsitePopupMenusController

  before_filter :require_business_website

  def new
    return redirect_to busine_popup_menus_path, alert: '最多只可设置4个选项' if @website.website_popup_menus.count >= 4
    @menu = @website.website_popup_menus.new(menu_type: WebsitePopupMenu::ACTIVITY)
    render layout: 'application_pop'
  end

  
  private
    def find_pop_menu
      require_business_website
      @menu = @website.website_popup_menus.find params[:id]
    end

end
