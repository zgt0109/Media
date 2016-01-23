class Biz::WebsiteMenusController < ApplicationController
  include WxReplyMessage

  before_filter :require_wx_mp_user
  before_filter :set_website#, only: [:index, :new]
  before_filter :set_website_menu, only: [:show, :edit, :update, :destroy, :update_sorts, :sort, :sub_menu]


  def index
    @website_menus = @website.website_menus.root
  end

  def new
    @website_menu = @website.website_menus.new(menu_type: WebsiteMenu::ACTIVITY, parent_id: params[:parent_id].to_i)
    @menu_categories_selects = @website_menu.multilevel_menu params
    # @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
    @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
  end

  def edit
    @menu_categories_selects = @website_menu.multilevel_menu params
    # if @website_menu.menuable_type == 'EcSellerCat'
    #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid), category_id: @website_menu.menuable_id).to_a.slice(0, 2)
    # else
    #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
    # end
    @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
  end

  def create
    @website_menu = WebsiteMenu.new(params[:website_menu])
    if @website_menu.save
      # if current_site.can_show_introduce? && current_site.task1?
      #   current_site.update_attributes(show_introduce: 2)
      #   redirect_to website_menus_path(task: Time.now.to_i, task_menu_id: @website_menu.id), notice: '添加成功'
      # else
        redirect_to website_menus_path, notice: "添加成功"
      # end
    else
      @menu_categories_selects = @website_menu.multilevel_menu params
      # if @website_menu.menuable_type == 'EcSellerCat'
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid), category_id: @website_menu.menuable_id).to_a.slice(0, 2)
      # else
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
      # end
      @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
      flash[:alert] = "添加失败"
      render action: 'new'
    end
  end

  def update
    if @website_menu.update_attributes(params[:website_menu])
      redirect_to website_menus_path, notice: "保存成功"
    else
      @menu_categories_selects = @website_menu.multilevel_menu params
      # if @website_menu.menuable_type == 'EcSellerCat'
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid), category_id: @website_menu.menuable_id).to_a.slice(0, 2)
      # else
      #   @ec_seller_cat_selects = wshop_api_categories(wx_mp_user_open_id: @website_menu.website.try(:supplier).try(:wx_mp_user).try(:openid)).to_a.slice(0, 2)
      # end
      @ec_seller_cat_selects = [[1, []]] unless @ec_seller_cat_selects.present?
      flash[:alert] = "保存失败"
      render action: 'edit'
    end
  end

  def destroy
    return redirect_to :back, alert: '站点下面有子站点，不能直接删除，请先删除这个站点下面的子站点' if @website_menu.children.count > 0 # don't use @website_menu.has_children? here
    if @website_menu.destroy
      redirect_to :back, notice: '删除成功'
    else
      redirect_to :back, alert: @website_menu.errors.full_messages.join(',')
    end
  end

  def update_sorts
    #1:置顶， -1:置底
    website_menus = @website.website_menus.where(parent_id: @website_menu.parent.try(:id).to_i).order(:sort).all
    index = website_menus.to_a.index(@website_menu)
    website_menus.each_with_index{|menu, index| menu.sort = index + 1}
    if params[:type] == "up"
      return render text: 1 unless index - 1 >= 0
      website_menus[index].sort, website_menus[index - 1].sort =  website_menus[index - 1].sort, website_menus[index].sort
    elsif params[:type] == "down"
      return render text: -1 unless website_menus[index + 1]
      website_menus[index].sort, website_menus[index + 1].sort =  website_menus[index + 1].sort, website_menus[index].sort
    else
      sort_index = params[:index].to_i
      website_menus[index].sort = website_menus[sort_index].sort
      #靠后排
      if sort_index > index
        website_menus.each_with_index{|menu, i| menu.sort = menu.sort - 1 if i <= sort_index && i > index}
        #靠前排
      elsif sort_index < index
        website_menus.each_with_index{|menu, i| menu.sort = menu.sort + 1 if i >= sort_index && i < index}
      end
    end
    website_menus.each{|menu| menu.update_column('sort', menu.sort) if menu.sort_changed?}
    render text: '操作成功'
  end

  def sub_menu
    render partial: "sub_menu", collection: @website_menu.children.order(:sort), as: :sub_menu
  end
  
  def sort
    @website_menu.send(params[:type].to_sym)
    redirect_to website_menus_path, notice: '操作成功'
  end

  def find_activities
    @website_menu = @website.website_menus.find(params[:id]) if params[:id].present?
    ids = params[:ids].split(',').to_a.map{|f| f.to_i}

    #微服务中添加ktv预定
    #ids = [29, 48] if ids == [29]

    @activities = current_site.activities.valid.unexpired.where(activity_type_id: ids)
    ids.each{|f| @is_exist_activity_time = ActivityType.exist_activity_time.include?(f) }
    render :partial=> "activities"
  end

  def select_ec_category
    @ec_seller_cat_selects = []#wshop_api_categories(wx_mp_user_open_id: @website.try(:supplier).try(:wx_mp_user).try(:openid), category_id: params[:category_id])
    render partial: 'ec_selects'
  end

  def find_good
    render text: @website.try(:site).try(:ec_shop).try(:ec_items).to_a.select{|m| m.id == params[:id].to_i}.flatten.count
  end

  private

  def set_website
    @website = current_site.website
    return redirect_to websites_path, alert: '请先设置微官网' unless @website
  end

  def set_website_menu
    @website_menu = @website.website_menus.where(id: params[:id]).first
    return redirect_to website_menus_path, alert: '站点不存在或已删除' unless @website_menu
  end

end
