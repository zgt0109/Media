class Pro::BusinessController < WebsiteShared::WebsitesController
  before_filter :require_business_website, except: :index
  before_filter :require_business_industry, :set_website

  def address
  	render "pro/websites/address"
  end

  private
    def set_website
      @website = current_user.circle || current_user.wx_mp_user.create_circle
      @website = current_user.wx_mp_user.create_circle unless @website.circle_activity
    end

end
