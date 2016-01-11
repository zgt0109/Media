class Mobile::GroupsController < Mobile::BaseController
  layout 'mobile/group'

  def index
    session[:user_id] = params[:user_id] if params[:user_id].present?
    @group = @site.group
    @category = @group.group_categories.where(id: params[:category_id]).first
    conn = @group.get_category params
    @group_items = @group.group_items.seller_items.selling.where(conn)
    @body_class = "index"
    @categories = @group.group_categories.root.order(:sort)
    if params[:category_name].present?
      result = RestClient.get("#{WMALL_HOST}/api/shops/category.json?category=#{URI.encode params[:category_name]}&site_id=#{@site.id}")
      if result.present?
        shops = JSON.parse result
        shop_ids = shops['shops'].map{|s| s['id']}
        @group_items  = shop_ids.present? ? @group_items.where("groupable_id in (#{shop_ids.join(',')}) and groupable_type = 'Wmall::Shop'") : []
      end
    end
  #rescue
  #  render :text => "参数不正确"
  end
end
