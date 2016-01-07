class Pro::BusinessPrivilegesController < WebsiteShared::WebsiteBaseController
  before_filter :require_business_website, :find_business_shop
  before_filter :find_business_privilege, only: [:edit, :update, :destroy]
  layout 'application_pop'

  def index
    @business_privileges = @business_shop.business_privileges
    render layout: 'application_gm'
  end

  def new
    @business_privilege = BusinessPrivilege.new
    render :form
  end

  def create
    @business_privilege = @business_shop.business_privileges.build params[:business_privilege]
    if @business_privilege.save
      render layout: false
    else
      render :form
    end
  end

  def edit
    render :form
  end

  def update
    if @business_privilege.update_attributes(params[:business_privilege])
      render layout: false
    else
      render_with_notice :form, '保存失败'
    end
  end

  def destroy
    @business_privilege.destroy
    render js: "$('#row-#{@business_privilege.id}').remove(); showTip('success', '操作成功');"
  end

  private
    def find_business_shop
      @business_shop = @website.business_shops.find params[:business_shop_id]
    end

    def find_business_privilege
      @business_privilege = @business_shop.business_privileges.find params[:id]
    end
end