class Pro::BusineMenusController < WebsiteShared::WebsiteMenusController

  before_filter :require_business_industry, :require_business_website
  before_filter :set_website_menu, only: [:show, :edit, :update, :destroy, :reorder]

end
