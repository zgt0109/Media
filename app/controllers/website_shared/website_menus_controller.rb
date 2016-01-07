class WebsiteShared::WebsiteMenusController < WebsiteShared::WebsiteBaseController

  def index
    @website_menus = @website.website_menus
  end

  def new
    @website_menu = @website.website_menus.new(menu_type: WebsiteMenu::ARTICLE, parent_id: params[:parent_id].to_i)
    @website_menu.sort = @website.website_menus.where(parent_id: params[:parent_id].to_i).maximum(:sort).to_i + 1
    render layout: 'application_pop'
  end

  def edit
    render layout: 'application_pop'
  end

  def create
    @website_menu = WebsiteMenu.new(params[:website_menu])
    if @website_menu.save
      render "pro/website_menus/create", layout: false
    else
      render action: 'new', layout: 'application_pop'
    end
  end

  def update
    if @website_menu.update_attributes(params[:website_menu])
      flash[:notice] = "保存成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :edit, @website_menu.errors.full_messages.first, layout: 'application_pop'
    end
  end

  def destroy
    @website_menu.destroy
    respond_to do |format|
      format.js { render js: "$('#parent-menu-#{@website_menu.id}').remove();" }
      format.html { redirect_to :back }
    end
  end

  def reorder
    siblings = @website.website_menus.where(parent_id: @website_menu.parent_id).sorted.to_a
    siblings.each_with_index { |m, i| m.sort = i + 1 }
    @website_menu = siblings.find { |m| m.id == params[:id].to_i }
    @sibling = params[:sort] == "up" ? @website_menu.prev(siblings) : @website_menu.next(siblings)
    return render js: 'void(0);' unless @sibling

    @website_menu.sort, @sibling.sort = @sibling.sort, @website_menu.sort
    siblings.each do |m|
      m.update_column :sort, m.sort if m.sort_changed?
    end
    render "pro/website_menus/reorder"
  end

end
