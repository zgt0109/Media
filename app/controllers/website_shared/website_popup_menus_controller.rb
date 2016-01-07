class WebsiteShared::WebsitePopupMenusController < WebsiteShared::WebsiteBaseController
  before_filter :find_pop_menu, only: [:show, :edit, :update, :destroy]

  def index
    find_pop_menus
    @menu  = @website.website_popup_menus.build
  end
  
  def show
    render layout: 'application_pop'
  end
  
  def new
    return redirect_to website_popup_menus_path, alert: '最多只可设置4个选项' if @website.website_popup_menus.count >= 4
		@menu = @website.website_popup_menus.new(menu_type: WebsitePopupMenu::ACTIVITY)
    render layout: 'application_pop'
	end

  def edit
    render layout: 'application_pop'
  end
  
  def create
		@menu = @website.website_popup_menus.new(params[:website_popup_menu])
		if @menu.save
      find_pop_menus
      render "pro/website_popup_menus/create", layout: false
    else
      redirect_to :back, alert: "添加菜单失败，#{@menu.errors.full_messages.first}"
    end
	end
	
	def update
		if @menu.update_attributes(params[:website_popup_menu])
      find_pop_menus
      render "pro/website_popup_menus/create", layout: false
    else
      redirect_to :back, alert: "更新失败，#{@menu.errors.full_messages.first}"
    end
	end

  def destroy
    @menu.destroy
    @menus_count = @website.website_popup_menus.count
    render "pro/website_popup_menus/destroy"
  end

  private
    def find_pop_menus
      @menus = @website.website_popup_menus.order(:sort)
    end

end
