class Pro::WebsitePopupMenusController < WebsiteShared::WebsitePopupMenusController
  before_filter :set_life_website


  private
    def find_pop_menu
      set_life_website
      @menu = @website.website_popup_menus.find params[:id]
    end

end
