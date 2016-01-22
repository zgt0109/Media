class Biz::ShopsController < ApplicationController
  include Biz::ShopRelatedPathHelper
  layout 'micro_shop'
  helper_method :current_shop_branch, :current_shop_account, :current_shop_vip_user, :hotel_branch_path

  skip_before_filter *ADMIN_FILTERS
  before_filter :require_shop_supplier
  before_filter :require_shop_branch, :require_privilege, except: [ :sign_in, :sign_out ]

  def sign_in
    return render layout: false if request.get?
    return redirect_to :back, alert: '验证码不正确' unless valid_verify_code? params[:verify_code]
    sub_account = current_shop_account.shop_branch_sub_accounts.where(username: params[:name]).first
    return redirect_to :back, alert: '门店名称不正确' unless sub_account
    return redirect_to :back, alert: '密码不正确' if !sub_account.authenticate( params[:password] )
    sign_in!(sub_account.id)
  end

  def sign_out
    session[:sub_account_id] = session[:shop_supplier_id] = nil
    redirect_to shops_sign_in_path, notice: '退出成功'
  end

  def consume_reports
    @activity = current_shop_account.site.activities.coupon.show.first || current_shop_account.site.create_activity_for_coupon

    @search = current_shop_branch.consumes.joins("join coupons on coupons.id = consumes.consumable_id AND consumes.consumable_type = 'Coupon'").coupon.used.search(coupon_filter_search)

    @used_consumes = @search.select('count(*) used_count, DATE(used_at) used_date, sum(coupons.value) coupons_value').group('used_date').to_a

    @used_sns    = @used_consumes.sum(&:used_count)
    dates = [@used_consumes.first.try(:used_date), @used_consumes.last.try(:used_date)].compact
    min_date, max_date = dates.min, dates.max

    return @pag_consumes = Kaminari.paginate_array([]).page(params[:page]).per(20) if min_date.nil? || max_date.nil?

    @consumes_all = (min_date..max_date).map do |day|
      {
        day:          day.to_s,
        consume_used: @used_consumes.find{ |c| c.used_date == day }.try(:used_count),
        discount:     @used_consumes.find{ |c| c.used_date == day }.try(:coupons_value)
      }
    end

    @pag_consumes = Kaminari.paginate_array(@consumes_all).page(params[:page]).per(20)

    respond_to do |format|
     format.html
     format.xls
    end
  end

  def activity_consumes
    activity_type_id  = params[:activity_type_id].to_i
    consumable_id     = params[:consumable_id].to_i
    is_coupon         = (activity_type_id == 3)
    is_unfold         = (activity_type_id == 71)
    has_activity_type = (activity_type_id > 0)
    has_consumable_id = (consumable_id > 0)
    code              = params[:code]

    if !has_activity_type && !has_consumable_id && !code.present?
      consumes = current_shop_branch.consumes.activity.used + current_shop_branch.consumes.coupon.used + current_shop_branch.activity_consumes.used
    elsif has_activity_type
      if is_coupon
        consumes = current_shop_branch.consumes.coupon.used
      elsif is_unfold
        consumes = current_shop_branch.consumes.activity.used
      else
        consumes     = current_shop_branch.activity_consumes.used
        consumes_ids = consumes.select { |c|
          c.activity.try(:activity_type_id) == activity_type_id
        }.map(&:id)
        consumes     = consumes.where(id: consumes_ids)
      end

      if has_consumable_id
        field = (is_coupon || is_unfold) ? :consumable_id : :activity_id
        consumes = consumes.where(field => consumable_id)
      end

      if code.present?
        consumes = consumes.where(code: code).to_a
      end
    elsif !has_activity_type && code.present?
      consumes = current_shop_branch.consumes.coupon.used.where(code: code) + current_shop_branch.activity_consumes.where(code: code) + current_shop_branch.consumes.activity.used.where(code: code)
    end
    @activities   = search_activities_or_coupons
    @consumes     = consumes.sort { |x, y| y.used_at <=> x.used_at }
    @consumes_all = Kaminari.paginate_array(@consumes).page(params[:page])
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def vip_deals; end

  def point_gift_exchanges
    respond_to do |format|
      format.html
      format.json { render json: {aaData: current_shop_branch.consumes.point_gift_exchange_json} }
      format.xls {
        data = current_shop_branch.consumes.point_gift_exchange.recent.map(&:consumable)
        send_data(PointGift.export_excel(data, include_gift: true), xls_options)
      }
    end
  end

  def exchange_info
    @consume = current_shop_branch.exchanging_counsumes.where(code: params[:code]).first
    @exchange = @consume.try(:consumable)
    if !@consume.try(:used?) && !@consume.try(:expired?) && @exchange
      render json: {find_status: 1, gift_code: params[:code], point_gift_name: @exchange.point_gift.try(:name),
                    created_at: @exchange.try(:created_at).to_s[0..15],
                    expired_at: (@consume.expired_at.to_s[0..15].presence || '长期有效')}
    else
      render json: {find_status: 0}
    end
  end

  def use_exchange
    @consume = current_shop_branch.exchanging_counsumes.where(code: params[:gift_code]).first
    if @consume.try(:use!, current_shop_branch )
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), alert: '操作失败'
    end
  end

  # 核销活动SN码
  def use_consume
    @consume = params[:consume_class].constantize.find_by_id(params[:consume_id])
    if @consume
      @consume.use!(current_shop_branch)
      flash.notice = '使用成功'
    else
      flash.alert = '使用失败'
    end
    respond_to do |format|
      format.js {render js: 'location.reload()'}
      format.html {redirect_to shops_vip_deals_path(session[:shop_supplier_id])}
    end
  rescue => e
    flash.alert = "使用失败：#{e.message}"
    respond_to do |format|
      format.js {render js: 'location.reload()'}
      format.html {redirect_to shops_vip_deals_path(session[:shop_supplier_id])}
    end
  end

  def vip_consumes
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    @today_transactions = current_shop_branch.vip_user_transactions.by_pay.where("date(created_at) = ?",@today)
    @yesterday_transactions = current_shop_branch.vip_user_transactions.by_pay.where("date(created_at) = ?",@today-1.day)
    @total_transactions = current_shop_branch.vip_user_transactions.by_pay.order('created_at DESC')
    respond_to do |format|
      format.html
      format.json { render json: {aaData: current_shop_branch.vip_user_transactions_pay_json} }
      format.xls { send_data(VipUserTransaction.export_excel(@total_transactions,"money"), xls_options) }
    end
  end

  def highchart
    @date = params[:created_date].present? ? params[:created_date] : "one_weeks"
    @today = Date.today
    @today_transactions = current_shop_branch.vip_user_transactions.by_pay.where("date(created_at) = ?",@today)
    @yesterday_transactions = current_shop_branch.vip_user_transactions.by_pay.where("date(created_at) = ?",@today-1.day)
    @total_transactions = current_shop_branch.vip_user_transactions.by_pay
  end

  def find_vip_user
    vip_user = current_shop_account.vip_users.visible.visible.where(params[:select_type] => params[:option_value]).first rescue nil
    return render json: {status: 0, user_status: '不存在'} if vip_user.nil?
    name = vip_user.name + "(#{vip_user.vip_grade_name})"
    usable_privileges = vip_user.usable_privileges.transaction_names_by_category(params[:modal])
    render json: {usable_privileges: usable_privileges, vip_user_id: vip_user.id, name: name, usable_amount: vip_user.usable_amount, usable_points: vip_user.usable_points, user_status: vip_user.status_name, vip_user_no: vip_user.user_no, vip_user_mobile: vip_user.mobile}
  end

  def find_activities
    return render json: {collection: search_activities_or_coupons}
  end

  # 查找活动SN码
  def find_consume
    activity_type = params[:activity_type].to_i
    if [2, 4, 5, 8, 25, 28, 64, 82].include?(activity_type)
      consume = current_shop_account.activity_consumes.by_activity_type(activity_type).unused.unexpired.where(code: params[:code]).first
    elsif activity_type == 62
      consume = current_shop_account.consumes.unused.unexpired.coupon_use_start.readonly(false).find_by_code(params[:code])
    elsif activity_type == 70
      consume = current_shop_account.consumes.recommend.unused.unexpired.readonly(false).find_by_code(params[:code])
    elsif activity_type == 71
      consume = current_shop_account.consumes.unfold.unused.unexpired.readonly(false).find_by_code(params[:code])
    end

    if consume
      if consume.is_a?(Consume)  && consume.wx_prize_name.present?
        name = consume.wx_prize_name
      else
        name   = VipUser.where(wx_user_id: consume.wx_user_id).first.try(:name)
      end

      if consume.is_a?(Consume)
        if consume.consumable_type == 'Coupon'
          coupon = consume.coupon
          if coupon.limited_for?(current_shop_branch)
            return render json: { find_status: -1 }
          else
            return render json: { find_status: 2, consume_class: 'Consume', consume_id: consume.id, code: consume.code, activity_type: '优惠券', activity_name: consume.consumable.try(:name), created: consume.created_at.to_s, status: consume.state_name, mobile: consume.mobile, name: name }
          end
        elsif consume.consumable_type == 'Activity'
          if consume.activity_can_use?
            consumable_activity = Activity.find_by_id(consume.consumable_id)
              return render json: { find_status: 1, consume_class: 'Consume', consume_id: consume.id, code: consume.code, activity_type: consume.consumable.try(:activity_type).try(:name), activity_name: consume.consumable.try(:name), created: consume.created_at.to_s, status: consume.state_name, mobile: consume.mobile, name: name }
          else
            return render json: { find_status: -1 }
          end
        end
      elsif consume.is_a?(ActivityConsume)
        return render json: { find_status: 1, consume_class: 'ActivityConsume', consume_id: consume.id, code: consume.code, activity_type: consume.activity.try(:activity_type).try(:name), activity_name: consume.activity.try(:name), created: consume.created_at.to_s, status: consume.status_text, mobile: consume.mobile, name: name }
      end
    end
    return render json: { find_status: 0 }
  end

  def save_point
    points = params[:points].to_i
    return redirect_to :back, alert: '积分必须大于0' if points <= 0

    if params[:direction_type] == '1'
      if current_shop_vip_user.increase_points!(points)
        current_shop_vip_user.point_transactions.create direction_type: PointTransaction::ADJUST_IN, points: points, supplier_id: current_shop_account.id, shop_branch_id: current_shop_branch.id, description: params[:description]
        flash[:notice] = "增加成功"
      else
        return redirect_to :back, alert: '增加失败,积分最小值为0'
      end
    else
      if current_shop_vip_user.decrease_points!(points)
        current_shop_vip_user.point_transactions.create direction_type: PointTransaction::OUT, points: points, supplier_id: current_shop_account.id, shop_branch_id: current_shop_branch.id, description: params[:description]
        flash[:notice] = "减少成功"
      else
        return redirect_to :back, alert: '减少失败，积分最小值为0'
      end
    end

    if params[:source] == 'branch'
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      render inline: '<script>parent.location.reload();</script>'
    end
  end

  def save_money
    amount, direction = params[:amount].to_f, params[:direction]
    return redirect_to :back, alert: '金额必须大于0' if amount <= 0

    direction_type         = { "1" => "增加", "2" => "减少", "3" => "充值", "4" => "消费" }[ direction ]
    error_message          = Hash.new("操作失败，金额最小值为0").merge!("4" => "可用余额不足，请充值后消费")[ direction ]
    params[:amount_source] = { "3" => VipUserTransaction::SHOP_PAY_UP, "4" => VipUserTransaction::SHOP_PAY_DOWN }[ direction ]

    success = current_shop_vip_user.increase_amount!(amount,direction_type,params) if ["1","3"].include?(direction)
    success = current_shop_vip_user.decrease_amount!(amount,direction_type,params) if ["2","4"].include?(direction)

    return redirect_to :back, alert: error_message unless success
    flash[:notice] = "#{direction_type}成功"

    if params[:source] == 'branch'
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      render inline: '<script>parent.location.reload();</script>'
    end
  end

  def transaction_check
    amount = params[:amount].to_f
    if params[:direction_type] == '1' || params[:direction_type] == '3'
      recharge_point_privilege = current_shop_vip_user.recharge_point_privilege(amount)
      recharge_discount_privilege = current_shop_vip_user.recharge_discount_privilege(amount)
      recharge_money_privilege = current_shop_vip_user.recharge_money_privilege(amount)
      @selected_privilege_ids = [recharge_discount_privilege.try(:id), recharge_point_privilege.try(:id), recharge_money_privilege.try(:id)].compact
      @pay_amount = current_shop_vip_user.recharge_discounted_amount(amount).to_f.round(2)
      @given_points = current_shop_account.giving_points(amount, PointType::RECHARGE, {}, current_shop_vip_user, pay: false)
      @given_moneys = current_shop_vip_user.give_money(amount)
      @form = 'charge'
    elsif params[:direction_type] == '2' || params[:direction_type] == '4'
      consume_point_privilege = current_shop_vip_user.consume_point_privilege(amount)
      consume_discount_privilege = current_shop_vip_user.consume_discount_privilege(amount)
      @selected_privilege_ids = [consume_discount_privilege.try(:id), consume_point_privilege.try(:id)].compact
      @pay_amount = current_shop_vip_user.consumed_amount(amount).to_f.round(2)
      @given_points = current_shop_account.giving_points(amount, PointType::CONSUME, {}, current_shop_vip_user, pay: false)
      @form = "consume"
    end

    render "biz/vip_users/transaction_check"
  end

  #套餐发放记录
  def package_users
    @total_package_users = current_shop_branch.vip_packages_vip_users.latest
    @search = @total_package_users.search(params[:search])
    @package_users = @search.page(params[:page])
    @vip_package_id = params[:search][:vip_package_id] if params[:search]

    respond_to do |format|
      format.html
      format.xls { send_data(VipPackagesVipUser.export_excel(@search), xls_options) }
    end
  end

  #套餐核销记录
  def item_consumes
    @total_item_consumes = current_shop_branch.vip_package_item_consumes.used.latest
    @search = @total_item_consumes.search(params[:search])
    @item_consumes = @search.page(params[:page])

    respond_to do |format|
      format.html
      format.xls { send_data(VipPackageItemConsume.export_excel(@search), xls_options) }
    end
  end

  #套餐发放
  def save_release
    @vip_package = current_shop_account.vip_card.vip_packages.where(id: params[:vip_package_id]).first
    vip_user = current_shop_account.vip_users.visible.where(id: params[:vip_user_id]).first
    return render_with_alert :release, '该会员不存在', layout: 'application_pop' unless vip_user
    return render_with_alert :release, '发放失败', layout: 'application_pop' unless @vip_package
    VipPackageItemConsume.transaction do
      vip_packages_vip_users = @vip_package.vip_packages_vip_users.new(site_id: @vip_package.site_id,
                                                                        vip_user_id: vip_user.id,
                                                                        shop_branch_id: current_shop_branch.id,
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
                                                                    package_item_price: vp.vip_package_item.price)}
        end
        redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
      else
        redirect_to shops_vip_deals_path(session[:shop_supplier_id]), alert: '操作失败'
      end
    end
  end

  #套餐核销
  def update_consumes
    item_consume = current_shop_account.vip_package_item_consumes.where(sn_code: params[:sn_code]).first
    if item_consume.try(:can_use?)
      item_consume.update_attributes(status: VipPackageItemConsume::USED, shop_branch_id: current_shop_branch.id)
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), notice: '操作成功'
    else
      redirect_to shops_vip_deals_path(session[:shop_supplier_id]), alert: '操作失败'
    end
  end

  def find_vip_package_item
    item_consume = current_shop_account.vip_package_item_consumes.where(sn_code: params[:sn_code]).first
    if (current_shop_branch.available_vip_packages.pluck(:id).include?(item_consume.try(:vip_package_id)) || !item_consume.try(:vip_package).try(:shop_branch_limited?)) && item_consume.try(:can_use?)
      render json: {find_status: 1, sn_code: params[:sn_code], item_name: item_consume.vip_package_item.name,
                    vip_user_name: item_consume.vip_user.name, vip_user_mobile: item_consume.vip_user.mobile,
                    create_time: item_consume.created_at.to_date, out_time: item_consume.vip_packages_vip_user.expired_at.to_date,
                    status: item_consume.human_status_name}
    else
      render json: {find_status: 0}
    end
  end

  #发放套餐默认余额支付
  def use_usable_amount
    vip_user = current_shop_account.vip_users.visible.where(id: params[:vip_user_id]).first
    vip_package = current_shop_account.vip_card.vip_packages.where(id: params[:vip_package_id]).first
    render json: {status: (vip_user && vip_package && vip_user.usable_amount >= vip_package.price ? true : false)}
  end

  private
    def coupon_filter_search
      search = params[:search].to_h
      search['used_at_gte'] << ' 00:00:00' if search['used_at_gte'].present?
      search['used_at_lte'] << ' 23:59:59' if search['used_at_lte'].present?
      search
    end

    def require_shop_supplier
      supplier = Account.find(params[:supplier_id])
      session[:shop_supplier_id] = supplier.id

      sub_account_id = Des.decrypt(params[:said])
      sign_in!(sub_account_id) if sub_account_id && supplier.shop_branch_sub_accounts.where(id: sub_account_id).exists?
    end

    def require_shop_branch
      return redirect_to shops_sign_in_path, alert: '无法操作，商户已停用该账号' if current_sub_account.try(:disabled?)
      return redirect_to shops_sign_in_path, alert: "您还没有登录" unless current_shop_branch
    end

    def require_privilege
      has_privilege = true
      has_privilege = can?('manage_vip_gift_exchange')     if action_name =~ /exchange/
      has_privilege = can?('view_vip_transactions')        if action_name =~ /consumes/
      has_privilege = (can_manage_any_vip? || can_manage_marketing_sncode?)  if action_name == 'vip_deals'
      has_privilege = can?('manage_vip_package_release')   if action_name =~ /package_users|save_release/
      has_privilege = can?('manage_vip_package_write_off') if action_name =~ /item_consumes|update_consumes|find_vip_package_item/
      has_privilege = can_manage_marketing_sncode?      if action_name =~ /coupon_consumes|activity_consumes/
      return redirect_to shops_sign_in_path, alert: "您没有权限访问该页面" unless has_privilege
    end

    def current_shop_vip_user
      @vip_user = current_shop_account.vip_users.visible.find(params[:id])
    end

  def search_activities_or_coupons
      return [] if params[:activity_type_id].blank?

      activity_type_id = params[:activity_type_id].to_i
      collection = current_shop_account.activities.where(activity_type_id: activity_type_id)
      collection = collection.first.coupons.normal rescue Coupon.none if activity_type_id == 3
      collection.pluck([:name, :id]).unshift(['全部', ''])
    end

    def can?(do_action)
      current_sub_account.can?(do_action)
    end

    def xls_options
     { type: 'text/excel;charset=utf-8; header=present', filename: Time.now.strftime('%Y_%m_%d_%H_%M_%S') + rand(99999).to_s + '.xls'}
    end

    def sign_in!(sub_account_id)
      session[:account_id] = nil # 为了共用同一套餐饮和外卖的功能，登录门店子系统需要退出当前商户的登录
      session[:sub_account_id] = sub_account_id

      signed_in_path = after_sign_in_path
      return redirect_to shops_sign_in_path(account_id: params[:account_id]), alert: '商户没有授权该门店管理权限' unless signed_in_path
      redirect_to signed_in_path if request.path != signed_in_path
    end

    delegate :can?, :can_any?, :can_manage_any_vip?, :can_manage_catering?, :can_manage_marketing_sncode?, :can_manage_takeout?, :can_manage_hotel?, to: :current_sub_account
end
