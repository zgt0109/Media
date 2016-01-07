class Mobile::GroupsController < Mobile::BaseController
  layout 'mobile/group'

  def index
    session[:wx_user_id] = params[:wx_user_id] if params[:wx_user_id].present?
    @group = @supplier.group
    @category = @group.group_categories.where(id: params[:category_id]).first
    conn = @group.get_category params
    @group_items = @group.group_items.seller_items.selling.where(conn)
    @body_class = "index"
    @categories = @group.group_categories.root.order(:sort)
    if params[:category_name].present?
      result = RestClient.get("#{WMALL_HOST}/api/shops/category.json?category=#{URI.encode params[:category_name]}&supplier_id=#{@supplier.id}")
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
