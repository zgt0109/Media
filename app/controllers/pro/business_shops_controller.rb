class Pro::BusinessShopsController < WebsiteShared::WebsiteBaseController
  before_filter :require_business_website
  before_filter :find_business_shop, except: [:index, :new, :create, :comments, :destroy_comment, :set_template]
  layout 'application_pop'

  def index
    @search = @website.business_shops.normal.sorted.search(params[:search])
    @business_shops = @search.page(params[:page])
    render layout: 'application_gm'
  end

  def new
    @business_shop = @website.business_shops.build
    @business_shop.build_activity(site: current_site, wx_mp_user: current_site.wx_mp_user, activity_type_id: ActivityType::BUSINESS_SHOP, status: Activity::SETTED)
    render :form
  end

  def create
    @business_shop = @website.business_shops.build params[:business_shop]
    if @business_shop.save
      flash[:notice] = '添加成功'
      render layout: false
    else
      render_with_alert :form, "保存失败，#{@business_shop.errors.full_messages.first}"
    end
  end

  def edit
    render :form
  end

  def update
    if @business_shop.update_attributes(params[:business_shop])
      flash[:notice] = '更新成功'
      render layout: false
    else
      render_with_alert :form, "保存失败，#{@business_shop.errors.full_messages.first}"
    end
  end

  def destroy
    @business_shop.delete!
    render js: "$('#row-#{@business_shop.id}').remove(); showTip('success', '操作成功');"
  end

  def vip_card_branch
    @vip_card_branch = @business_shop.vip_card_branch
  end

  def update_vip_card_branch
    if @business_shop.vip_card_branch.update_attributes params[:vip_card_branch]
    else
    end
  end

  def toggle_vip_card
    @business_shop.toggle! :enable_vip_card
    render js: "showTip('success', '操作成功');"
  end

  def comments
    @search   = Comment.where(commentable_type: 'BusinessShop', site_id: current_site.id).search(params[:search])
    @comments = @search.page(params[:page])
    render layout: 'application_gm'
  end

  def destroy_comment
    comment = Comment.where(commentable_type: 'BusinessShop', site_id: current_site.id).find params[:comment_id]
    comment.destroy
    render js: "$('#row-#{comment.id}').remove(); showTip('success', '删除成功');"
  end

  def business_shop_admin
    @business_shop_admin = @business_shop.business_shop_admin || @business_shop.create_business_shop_admin(username: "@#{@website.id}", password: '111111')
  end

  def update_business_shop_admin
    @business_shop_admin = @business_shop.business_shop_admin
    if @business_shop_admin.update_attributes(params[:business_shop_admin])
      flash[:notice] = "保存成功"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      flash[:alert] = "保存失败"
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    end
  end

  def group_activities
    ids = @business_shop.activities_business_shops.collect(&:activity_id)
    @total_group_activities = current_site.activities.where(["id not in (?) and status in (?) and now() < end_at and activity_type_id=14",ids.blank? ? "" : ids,[0,1]]).order('id DESC')
    @shop_activitys = current_site.activities.where(["id in (?)",ids]).order('id DESC').page(params[:page])
  end

  def update_group_activities
    if params[:activities_business_shop][:activity_id].blank?
      redirect_to :back, alert: '无法关联'
    else
      @activities_business_shop = @business_shop.activities_business_shops.new(params[:activities_business_shop])
      if @activities_business_shop.save
        redirect_to group_activities_business_shop_path(@business_shop), notice: '保存成功'
      else
        redirect_to :back, alert: '保存失败'
      end
    end
  end

  def delete_group_activities
    @business_shop.activities_business_shops.where(activity_id: params[:aid]).delete_all
    render js: "showTip('success', '操作成功');window.location.reload();"
  end

  def open_function
    @business_shop.toggle!(:open_function)
    render :nothing => true
  end

  def set_template
    @website_templates = WebsiteTemplate.order(:style_index).first(2)
    return render layout: 'application_gm' if request.get?
    @website.update_attributes(template_id: params[:template_id])
    render json: { message: '设置成功' }
  end

  private
    def find_business_shop
      @business_shop = @website.business_shops.find params[:id]
    end
end