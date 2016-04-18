class App::VipsController < App::BaseController
  skip_before_filter :verify_authenticity_token
  before_filter :block_non_wx_browser, :require_vip_card, :find_vip_user, except: [:map, :tenpay_notify, :tenpay_callback]
  before_filter :require_wx_user, except: [:map, :passwd, :edit_passwd, :find_passwd, :tenpay_notify, :tenpay_callback, :recharge_back, :vip_package_show]
  skip_before_filter :auth, :authorize, only: [:tenpay_notify, :tenpay_callback, :recharge_back]
  before_filter :require_vip_user, except: [ :index, :success, :signup, :apply, :shops, :map, :description, :send_sms, :mine, :gifts, :signin, :tenpay_notify, :tenpay_callback, :recharge_back, :vip_packages, :vip_package_show, :activate]
  layout 'app/vip'

  def index
    return if @vip_card.stopped? || @vip_user.nil?
    return render :pending if @vip_user.pending?
    return render :rejected if @vip_user.rejected?
    return render :freeze if @vip_user.freeze?
    return if @vip_user.abnormal?

    @message_count = @vip_user.vip_user_messages.unread.count
    @coupons_count = (@vip_user.user.activity_consumes.coupon.count + @vip_user.user.consumes.coupon.count) rescue 0
    @item_consumes = @site.vip_card.vip_packages.active.count
  end

  def apply; end

  def go_recharge
    DbRedis.set_vip_package_id(@site.id, @vip_user.id, params[:vip_package_id].presence)
    recharge_discount_privileges = @vip_user.recharge_discount_privileges
    recharge_point_privileges    = @vip_user.recharge_point_privileges
    recharge_money_privileges    = @vip_user.recharge_money_privileges
    @privileges                  = recharge_discount_privileges + recharge_point_privileges + recharge_money_privileges
  end

  def recharge
    order                 = params[:vip_recharge_order].merge(site_id: @site.id)
    amount                = order[:amount].to_f.round(2)

    order['pay_amount']   = @vip_user.recharge_discounted_amount(amount)
    order['given_points'] = @site.giving_points(amount, PointType::RECHARGE, {}, @vip_user, pay: false)

    @order                = @vip_user.vip_recharge_orders.create(order)
    if @order.alipay?
      payment             = @order.payment!
      redirect_to alipayapi_payment_url(payment)
    elsif @order.wxpayv2? || @order.wxpayv3?
      options = {
        callback_url: callback_payments_url,
        notify_url: notify_payments_url,
        merchant_url: app_vips_url({site_id: session[:site_id]})
      }
      @payment_request_params = @order.payment_request_params(options)
      render "app/vips/pay"
    elsif @order.tenpay?
      url = generate_tenpay_url  :order_id => @order.id,
        :subject => "会员卡#{@order.pay_type_name}充值 #{@order.order_no}",
        :body => "会员卡#{@order.pay_type_name}充值 #{@order.order_no} #{@order.amount}",
        :total_fee => (@order.pay_amount * 100).to_i,
        :out_trade_no => @order.order_no
      return redirect_to url
    end
    rescue => error
      logger.warn "group order payment_request failure:#{error.message}\n#{error.backtrace}"
      redirect_to :back, alert: "创建订单失败"
  end

  def tenpay_notify
    logger.info "----------- notify back #{params}------------------"
    @order = VipRechargeOrder.find(params[:order_id])
    render text: (@order.recharge! ? 'success' : 'fail')
  end

  def tenpay_callback
    logger.info "----------- into mobile call back #{params}------------------"
    @order = VipRechargeOrder.find(params[:order_id])
    redirect_to recharge_back_app_vips_url(order_id: @order.id)
  end

  def recharge_check
    amount                      = params[:amount].to_f
    recharge_point_privilege    = @vip_user.recharge_point_privilege(amount)
    recharge_discount_privilege = @vip_user.recharge_discount_privilege(amount)
    recharge_money_privilege    = @vip_user.recharge_money_privilege(amount)

    @selected_privilege_ids     = [recharge_discount_privilege.try(:id), recharge_point_privilege.try(:id), recharge_money_privilege.try(:id)].compact
    @pay_amount                 = @vip_user.recharge_discounted_amount(amount)
    @given_points               = @site.giving_points(amount, PointType::RECHARGE, {}, @vip_user, pay: false)
    @pay_amount                 = @pay_amount.to_f.round(2)
    @given_moneys               = @vip_user.give_money(amount)
  end

  def recharge_back
    @vip_package_id = DbRedis.get_vip_package_id(@site.id, @vip_user.id) if @vip_user
    @order = VipRechargeOrder.find_by_id(params[:order_id])
  end

  def signup
    return if request.get?
    return render json: {ajax_msg: {status: -3} } if @vip_card.sms_check? && (params[:captcha] != session[:captcha] || params[:mobile] != session[:mobile])
    return render json: {ajax_msg: { status: 0, cardnumer: @vip_user.user_no } } if @vip_user
    if params[:mobile].present? && @site.vip_users.visible.where(mobile: params[:mobile]).exists?
      render json: {ajax_msg: {status: -2} }
    else # VipUser不存在，创建一个
      Tryable.try_times!(3, sleep_seconds: 0.2) do
        @vip_user = @site.vip_users.create!(site_id: @site.id, user_id: session[:user_id], name: params[:uname], mobile: params[:mobile])
      end
      CustomField.create_or_update_for_vip_user(@vip_user, params[:custom_field])
      @vip_card.vip_api_setting.try(:open_card, @vip_user) if @vip_card.open_card?
      render json: {ajax_msg: { status: 1, cardnumer: @vip_user.user_no } }
    end
  rescue => error
    # logger.warn "vips sign up error: #{error}."
    SiteLog::Base.logger('vip', "vips sign up error: #{([error.message] + error.backtrace).join("\n")}")
    render json: {ajax_msg: {status: -1} }
  end

  def print;end

  def notes
    if request.post?
      vip_user_message = @vip_user.vip_user_messages.unread.find params[:id]
      render json: { error: !vip_user_message.update_attributes(is_read: true) }
    else
      is_read            = params[:is_read].presence && params[:is_read] == 'true'
      @vip_user_messages = @vip_user.vip_user_messages.read(is_read).latest.page(params[:page]) if @vip_user
    end
  end

  def info
    return if request.get?
    return render json: {notice: '验证码不正确' } if @vip_card.sms_check? && params[:captcha].to_i != session[:captcha].to_i

    if @vip_user.update_attributes(params[:vip_user])
      CustomField.create_or_update_for_vip_user(@vip_user, params[:custom_field])
      render json: { notice: '保存成功' }
    else
      render json: { notice: "保存失败：#{@vip_user.errors.full_messages.join("，")}" }
    end
  end

  def information;end

  def passwd
    return if request.get?
    options = params.slice(:password, :password_email).merge(can_validate: true).reject { |k, v| v.blank? }
    url     = params[:return_to].presence || information_app_vips_url
    notice  = @vip_user.update_attributes(options) ? "设置成功" : "设置失败"
    redirect_to url, notice: notice
  end

  def edit_passwd
    return if request.get?
    return redirect_to passwd_app_vips_url if @vip_user.authenticate(params[:password])
    redirect_to edit_passwd_app_vips_url, notice: "密码不正确"
  end

  def find_passwd
    return if request.get?
    return redirect_to :back, notice: "您还没有设置找回密码邮箱，请先设置找回密码邮箱" if @vip_user.password_email.blank?
    return redirect_to :back, notice: "邮箱不正确" if @vip_user.password_email != params[:password_email]
    @vip_user.update_attributes(password: rand(100000..999999))
    VipUserMailer.find_password_email(@vip_user).deliver
    redirect_to :back, notice: "您的新密码已经发送至您的邮箱，为确保支付安全，请尽快修改密码"
  end

  def signin
    @point_type = @site.point_types.normal.checkin.first
    return unless @vip_user
    @signined   = @vip_user.vip_user_signs.where(date: Date.today).exists?
    if request.post?
      return render json: { error: true, message: "商家没有开启签到送积分" } unless @vip_card.checkin_enabled?
      return render json: { error: true, message: "您今天已经签过到了" } if @signined
      return render json: { error: true, message: "商家没有开启签到送积分" } unless @vip_user.signin
      render json: {}
    else
      @first_day_of_month = params[:month].present? ? Date.parse(params[:month]).beginning_of_month : Date.today.beginning_of_month
      @last_day_of_month  = @first_day_of_month.end_of_month
      @vip_user_signs     = @vip_user.vip_user_signs.where('date between ? and ?', @first_day_of_month, @last_day_of_month).order('created_at DESC')
    end
  end

  def gifts
    @gifts = @site.point_gifts.exchangeable.latest.page(params[:page])
  end

  def gift
    @gift = @site.point_gifts.exchangeable.find(params[:id])
  end

  def exchanged
    @point_gift_exchanges = @vip_user.point_gift_exchanges.latest.page(params[:page])
  end

  def get_gift
    @gift = @site.point_gifts.exchangeable.find params[:id]
  end

  def exchange_gift
    @gift = @site.point_gifts.online.exchangeable.find params[:id]
    qty, vip_given_id = params[:qty].to_i, params[:vip_given_id]
    return redirect_to :back, alert: "兑换失败，兑换数量至少为1" if qty <= 0
    return redirect_to :back, alert: "兑换失败，该礼品仅适用于：#{@gift.vip_grade_names}" unless @gift.exchangeable_for?(@vip_user)
    return redirect_to :back, alert: "兑换失败，该礼品已兑换完毕" if @gift.sku_lack?
    return redirect_to :back, alert: "每个用户最多可兑换#{@gift.people_limit_count}次" if @gift.limit_count_for( @vip_user ) == 0
    return redirect_to :back, alert: "积分不足，无法兑换该礼品" unless @vip_user.exchange_gift(@gift, qty, vip_given_id)
    redirect_to exchanged_app_vips_url, notice: "兑换成功"
  end

  def shops
    return render text: '参数不正确' unless @site
    if params[:vip_package_id].present?
      vip_package = @vip_card.vip_packages.where(id: params[:vip_package_id]).first
      @shop_branches = vip_package.shop_branch_limited ? @site.shop_branches.used.where(id: vip_package.shop_branch_ids) : @site.shop_branches.used
    else
      @shop_branches = @site.shop_branches.used.any_shops(params[:ids].to_s.split(","))
    end
  end

  def points
    @points             = @vip_user.point_transactions
    month_time          = params[:month].present? ? Time.parse("#{params[:month]}-01") : Time.now
    @point_transactions = @points.by_direction_type(params[:type]).by_money(params[:type]).where(created_at: month_time.all_month).order('id desc') if params[:type] != "givens"
    @vip_givens         = @vip_user.vip_givens.point
    @givens             = @vip_givens.includes(:vip_care).where("? BETWEEN vip_givens.start_at AND vip_givens.end_at", month_time).order('id desc')
  end

  def consumes
    @pay_down              = @vip_user.vip_user_transactions.pay_down.sum(:amount)
    @point_transactions    = @vip_user.point_transactions.by_money("money")
    month_time             = params[:month].present? ? Time.parse("#{params[:month]}-01") : Time.now
    @vip_user_transactions = @vip_user.vip_user_transactions.by_pay.where(created_at: month_time.all_month).order('id desc')
  end

  def consume
    @vip_user_transaction = @vip_user.vip_user_transactions.by_pay.find params[:id]
  end

  def description
    @point_types = @site.point_types.normal.order("created_at desc")
    @vip_grades  = @vip_card.vip_grades.normal.sorted
  end

  def privileges
    @vip_privileges   = @vip_card.vip_privileges.active.order('created_at DESC')
  end

  def use_gift
    @point_gift_exchange = @vip_user.point_gift_exchanges.find params[:id]
    @point_gift          = @point_gift_exchange.point_gift
    @consume             = @point_gift_exchange.consume
    @shop_branches       = @site.shop_branches.used.any_shops(@point_gift.try(:shop_branch_ids))
    @shop_branch_options = [['请选择门店',''], ['商户总部', '0']] + @shop_branches.pluck(:name, :id)
  end

  def update_consumes
    return redirect_to :back, notice: "交易密码不正确" if !@site.user_password_correct?(params[:user_password])
    consume     = @vip_user.consumes.unused.unexpired.find(params[:id])
    gift        = consume.consumable.point_gift
    shop_branch = gift.shop_branches.used.find(params[:shop_branch_id]) if gift && params[:shop_branch_id].to_i > 0
    if consume.use!(shop_branch)
      redirect_to exchanged_app_vips_url(app_params), notice: "使用成功"
    else
      redirect_to :back, alert: "使用失败"
    end
  end

  def send_sms
    if request.referrer.to_s =~ /activate/
      return render json: { error: true, message: '找不到此手机号对应的会员，请确认手机号是否正确' } if !@site.vip_importings.where(mobile: params[:phone]).exists?
      return render json: { error: true, message: '该手机号已被使用' } if @site.vip_users.visible.where(mobile: params[:phone]).exists?
    end
    session[:captcha], session[:mobile] = rand(100000..999999).to_s, params[:phone].to_s
    SmsAlidayu.new.send_code_for_verify(session[:mobile], session[:captcha])
    render json: {}
  end

  def mine
    return if @vip_card.stopped? || @vip_user.nil? || @vip_user.abnormal?
    @pay_down      = @vip_user.vip_user_transactions.pay_down.sum(:amount)
    @message_count = @vip_user.vip_user_messages.unread.count
    @coupons_count = (@vip_user.user.activity_consumes.coupon.count + @vip_user.user.consumes.coupon.count) rescue 0
  end

  #会员卡套餐
  def vip_packages
    if params[:type]
      @vip_packages_vip_users = @vip_user.vip_packages_vip_users.send(params[:type]).latest.includes(:vip_package) rescue []
    else
      @vip_packages = @vip_card.vip_packages.active.latest
    end
  end

  #套餐详情
  def vip_package_show
    @vip_package = @vip_card.vip_packages.show.find(params[:id])
  end

  #服务详情
  def my_consume_show
    @vip_package = @vip_card.vip_packages.show.where(id: params[:vp_id]).first
    @item_consume = @vip_user.vip_package_item_consumes.where(id: params[:id]).first
    unless @item_consume
      package_item = @site.vip_card.vip_package_items.find(params[:vpi_id])
      @item_consume = @vip_user.vip_package_item_consumes.create(site_id: @site.id,
                                                                vip_package_id: @vip_package.id,
                                                                vip_packages_vip_user_id: params[:vpvu_id],
                                                                vip_package_item_id: package_item.id,
                                                                status: VipPackageItemConsume::UNUSED,
                                                                package_item_name: package_item.name,
                                                                package_item_price: package_item.price)
    end
    @count = @item_consume.vip_packages_vip_user.vip_package_item_consumes.unused.where(vip_package_item_id: @item_consume.vip_package_item_id).count
    @total_count = @vip_package.vip_package_items_vip_packages.where(vip_package_item_id: @item_consume.vip_package_item_id).first.items_count
  end

  #余额支付
  def buy_vip_package
    @package = @vip_card.vip_packages.show.find(params[:id])
    @amount_status = @vip_user.try(:usable_amount) >= @package.price
  end

  #支付密码
  def by_usable_amount
    @package = @vip_card.vip_packages.show.find(params[:id])
    return redirect_to passwd_app_vips_url(return_to: by_usable_amount_app_vips_url(id: @package.id)) if @vip_user.password_digest.blank?
  end

  #确认支付
  def save_release
    if @vip_user.authenticate( params[:password] )
      @vip_package = @vip_card.vip_packages.show.find(params[:id])
      return redirect_to :back, alert: "购买失败，余额不足" if @vip_user && @vip_package && @vip_user.usable_amount < @vip_package.price
      VipPackageItemConsume.transaction do
        vip_packages_vip_users = @vip_package.vip_packages_vip_users.new(site_id: @vip_package.site_id,
                                                                          vip_user_id: @vip_user.id,
                                                                          expired_at: Time.now+@vip_package.expiry_num.month,
                                                                          package_name: @vip_package.name,
                                                                          package_price: @vip_package.price,
                                                                          payment_type: VipPackagesVipUser::BY_BALANCE)
        if vip_packages_vip_users.update_vip_user_amount(VipUserTransaction::WEB_PAY_DOWN)
          @vip_package.vip_package_items_vip_packages.each do |vp|
            vp.items_count.times{@vip_user.vip_package_item_consumes.create(site_id: @vip_package.site_id,
                                                                      vip_package_id: vp.vip_package_id,
                                                                      vip_packages_vip_user_id: vip_packages_vip_users.id,
                                                                      vip_package_item_id: vp.vip_package_item_id,
                                                                      status: VipPackageItemConsume::UNUSED,
                                                                      package_item_name: vp.vip_package_item.name,
                                                                      package_item_price: vp.vip_package_item.price)} if vp.items_count > 0
          end
          redirect_to buy_success_app_vips_url(price: @vip_package.price), notice: "购买成功"
        else
          redirect_to :back, alert: "购买失败"
        end
      end
    else
      redirect_to :back, alert: '密码不正确'
    end
  end

  #支付成功
  def buy_success;end

  def activate
    return redirect_to app_vips_url, notice: '商家没有开启会员导入功能' if @vip_card.vip_importing_disabled?
    return if request.get?
    mobile, captcha = session[:mobile], session[:captcha]
    return render js: "alert('验证码不正确')" if captcha.blank? || params[:captcha] != captcha || params[:mobile] != mobile
    session[:captcha] = session[:mobile] = nil
    vip_importing = @site.vip_importings.where(mobile: mobile).first
    return render js: "alert('手机号码不存在');" unless vip_importing
    vip_user = vip_importing.activate_by(@user)
    if vip_user.blank?
      render js: "alert('领卡失败：您已经领取过会员卡了');"
    elsif vip_user.persisted?
      render js: "alert('恭喜，您已成为线上会员！');location.href='#{app_vips_url}'"
    else
      render js: "alert('领卡失败： #{vip_user.full_error_message}');"
    end
  end

  def inactive
    return if request.get?
    if @vip_user.update_attributes(name: params[:name], mobile: params[:mobile])
      @vip_user.normal!
      render js: "alert('恭喜，您已成为线上会员！');location.href='#{app_vips_url}'"
    else
      render js: "alert('激活失败： #{@vip_user.full_error_message}');"
    end
  end

  private
    def require_vip_card
      @vip_card = @site.vip_card
      session[:activity_id] = @vip_card.try(:activity_id)
      render inline: "<h1>该商家没有提供会员卡</h1>", content_type: 'text/html' and return false unless @vip_card
    end

    def generate_tenpay_url(options)
      options = {
          :return_url => tenpay_callback_app_vips_url(site_id: session[:site_id], order_id: options[:order_id]),
          :notify_url => tenpay_notify_app_vips_url(site_id: session[:site_id], order_id: options[:order_id]),
          :spbill_create_ip => request.ip
      }.merge(options)
      tenpay = @site.payment_settings.tenpay.first
      JaslTenpay::Service.create_interactive_mode_url(options, tenpay.partner_id, tenpay.partner_key)
    end

    def find_vip_user
      @vip_user = @site.vip_users.visible.where(user_id: session[:user_id]).first
    end

    def require_vip_user
      unless @vip_user
        text = "<h1>会员不存在，请输入关键字 “#{@vip_card.activity.keyword}” 再次进入该页面</h1>"
        render inline: text, content_type: 'text/html' and return false
      end

      return render :pending if @vip_user.pending?
      return render :rejected if @vip_user.rejected?
      return render :freeze if @vip_user.freeze?
      return if @vip_user.inactive?

      vip_checker = VipUserChecker.new(@vip_user)
      redirect_to app_vips_url(app_params), notice: vip_checker.error_message if vip_checker.error?
    end

end
