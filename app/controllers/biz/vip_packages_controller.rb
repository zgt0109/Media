class Biz::VipPackagesController < Biz::VipController
  
  before_filter :set_vip_card
  before_filter :find_vip_package, only: [:edit, :update, :destroy, :save_release, :use_usable_amount]
  before_filter :first_shop_branch, only: [:new, :update, :create, :edit]
  before_filter :find_vip_package_items, only: [ :new, :create, :edit, :update ]

  def index
    @search = @vip_card.vip_packages.show.latest.search(params[:search])
    @packages = @search.page(params[:page])
  end

  def package_users
    @total_package_users = current_site.vip_packages_vip_users.latest
    @search = @total_package_users.search(params[:search])
    @package_users = @search.page(params[:page])
    @vip_package_id = params[:search][:vip_package_id] if params[:search]

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipPackagesVipUser.export_excel(@search),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def item_consumes
    @total_item_consumes = current_site.vip_package_item_consumes.used.latest
    @search = @total_item_consumes.search(params[:search])
    @item_consumes = @search.page(params[:page])

    respond_to do |format|
      format.html
      format.xls {
                send_data(VipPackageItemConsume.export_excel(@search),
                :type => "text/excel;charset=utf-8; header=present", 
                :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/,'_') + rand(99999).to_s + ".xls")
              }
    end
  end

  def new
    @vip_package = @vip_card.vip_packages.new
    render :form#, layout: 'application_pop'
  end

  def edit
    render :form#, layout: 'application_pop'
  end

  def create
    params[:vip_package][:vip_package_items_vip_packages_attributes] = params[:vip_package][:vip_package_items_vip_packages_attributes].to_h.values
    params[:vip_package][:vip_package_items_vip_packages_attributes].delete_if { |h| !h.key?(:vip_package_item_id) || h[:items_count].blank? }
    @vip_package = @vip_card.vip_packages.new(params[:vip_package].merge!(site_id: @vip_card.site_id))
    if @vip_package.save
      redirect_to vip_packages_path, notice: "保存成功"
    else
      render_with_alert :form, "保存失败，#{@vip_package.errors.full_messages.join(', ')}"#, layout: 'application_pop'
    end
  end

  def update
    params[:vip_package][:vip_package_items_vip_packages_attributes] = params[:vip_package][:vip_package_items_vip_packages_attributes].to_h.values
    params[:vip_package][:vip_package_items_vip_packages_attributes].each do |h|
      h.delete :_destroy if h[:_destroy].blank?
      h.delete :id if h[:id].blank?
    end
    params[:vip_package][:vip_package_items_vip_packages_attributes].delete_if do |h|
      if h[:id].blank?
        !h.key?(:vip_package_item_id) || h[:items_count].blank?
      end
    end
    if @vip_package.update_attributes(params[:vip_package])
      redirect_to vip_packages_path, notice: "保存成功"
    else
      render_with_alert :form, "保存失败，#{@vip_package.errors.full_messages.join(', ')}"#, layout: 'application_pop'
    end
  end

  def destroy
    if params[:status] == "set_status"
      @vip_package.active? ? @vip_package.stopped! : @vip_package.active!
      render js: "$('#package-#{@vip_package.id}').find('#status_name').html('#{@vip_package.status_name}');$('#package-#{@vip_package.id}').find('#edit_status').html('#{@vip_package.active? ? '停用' : '开启'}');showTip('success', '#{@vip_package.status_name}');"
    else
      @vip_package.update_attributes(status: VipPackage::DELETED)
      render js: "$('#package-#{@vip_package.id}').remove();"
    end
  end

  def find_vip_user
    vip_user = current_site.vip_users.visible.where(user_no: params[:user_no]).first
    if vip_user
      render json: {user_status: 1, user_no: params[:user_no], name: vip_user.name + "(#{vip_user.vip_grade_name})", mobile: vip_user.mobile, usable_amount: vip_user.usable_amount}
    else
      render json: {user_status: 0}
    end
  end

  #发放套餐
  def release
    render layout: 'application_pop'
  end

  def save_release
    vip_user = current_site.vip_users.visible.where(user_no: params[:user_no]).first
    return render_with_alert :release, '该会员不存在', layout: 'application_pop' unless vip_user
    return render_with_alert :release, '发放失败', layout: 'application_pop' unless @vip_package
    VipPackageItemConsume.transaction do
      vip_packages_vip_users = @vip_package.vip_packages_vip_users.new(site_id: @vip_package.site_id,
                                                                        vip_user_id: vip_user.id,
                                                                        description: params[:description],
                                                                        expired_at: Time.now+@vip_package.expiry_num.month,
                                                                        package_name: @vip_package.name,
                                                                        package_price: @vip_package.price,
                                                                        payment_type: params[:payment_type])
      if vip_packages_vip_users.update_vip_user_amount(VipUserTransaction::SHOP_PAY_DOWN)
        @vip_package.vip_package_items_vip_packages.each do |vp|
          vp.items_count.times{vip_user.vip_package_item_consumes.create(site_id: @vip_package.site_id,
                                                                    vip_package_id: vp.vip_package_id,
                                                                    vip_packages_vip_user_id: vip_packages_vip_users.id,
                                                                    vip_package_item_id: vp.vip_package_item_id,
                                                                    status: VipPackageItemConsume::UNUSED,
                                                                    package_item_name: vp.vip_package_item.name,
                                                                    package_item_price: vp.vip_package_item.price)} if vp.items_count > 0
        end
        flash[:notice] = "发放成功"
        render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
      else
        render_with_alert :release, '发放失败', layout: 'application_pop'
      end
    end
  end

  #核销服务
  def use_package
    render layout: 'application_pop'
  end

  def find_vip_package_item
    item_consume = current_site.vip_package_item_consumes.where(sn_code: params[:sn_code]).first
    if item_consume.try(:can_use?)
      vip_package = @vip_card.vip_packages.where(id: item_consume.vip_package_id).first
      shop_html = vip_package.get_shop_html
      item_html = item_consume.get_item_html
      render json: {consume_status: 1, shop_html: shop_html, item_html: item_html, sn_code: params[:sn_code]}
    else
      render json: {consume_status: 0}
    end
  end

  def update_consumes
    item_consume = current_site.vip_package_item_consumes.where(sn_code: params[:sn_code]).first
    if item_consume.try(:can_use?)
      item_consume.update_attributes(status: VipPackageItemConsume::USED)
      flash[:notice] = "核销成功"
      render inline: "<script>window.parent.document.getElementById('weisiteModal').style.display='none';window.parent.location.reload();</script>"
    else
      render_with_alert :use_package, '核销失败', layout: 'application_pop'
    end
  end

  #发放套餐默认余额支付
  def use_usable_amount
    vip_user = current_site.vip_users.visible.where(user_no: params[:user_no]).first
    render json: {status: (vip_user && @vip_package && vip_user.usable_amount >= @vip_package.price ? true : false)}
  end

  private

    def find_vip_package
      @vip_package = @vip_card.vip_packages.where(id: params[:id]).first
    end

    def find_vip_package_items
      @package_items = @vip_card.vip_package_items.normal
    end

    def first_shop_branch
      if @vip_package.try(:shop_branch_ids).present?
        @shop_branchs = []
        city_ids = current_site.shop_branches.used.where(id: @vip_package.try(:shop_branch_ids)).uniq.pluck(:city_id)
        city_ids.each_with_index do |city_id,index|
          branch = current_site.shop_branches.used.where(city_id: city_id)
          @shop_branchs << branch
          if index == 0
            @province_id = branch.first.province_id
            @city_id = branch.first.city_id
          end
        end
      else
        @province_id = 9
        @city_id = 73
        @shop_branchs = [current_site.shop_branches.used.where(province_id: 9, city_id: 73)]
      end
    end

end