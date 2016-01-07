class Pro::WebsiteMenusController < WebsiteShared::WebsiteMenusController
  before_filter :set_life_website
  before_filter :set_website_menu, only: [:show, :edit, :update, :destroy, :reorder]
end
