class Api::V1::VipsController < Api::BaseController
  before_filter :cors_set_access_control_headers
  before_filter :set_users, except: [:pay, :spm_points, :spm_vip]
  EC_SOURCE, HOTEL_SOURCE, SPM_SOURCE = 'winwemedia_ec', 'winwemedia_hotel', 'winwemedia_spm'
  # 会员卡余额支付接口 site_id, supplier_id, open_id, out_trade_no, amount, subject, body, source, trade_token
  def pay
    open_id, site_id, trade_token, out_trade_no, subject, body = params.values_at(:open_id, :site_id, :trade_token, :out_trade_no, :subject, :body)
    wx_mp_user = WxMpUser.where(site_id: site_id).first
    amount = params[:amount].to_f
    return render json: { errcode: 1, errmsg: "参数不正确，金额或折扣后金额必须大于0" } if amount <= 0
    return render json: { errcode: 1, errmsg: "参数不正确，找不到公众账号" } unless wx_mp_user && wx_mp_user.site
    vip_user = wx_mp_user.site.vip_users.visible.where(trade_token: params[:trade_token]).first
    vip_checker = VipUserChecker.new(vip_user, open_id)
    return render json: { errcode: 1, errmsg: vip_checker.error_message } if vip_checker.error?
    return render json: { errcode: -1, errmsg: "会员余额不足，无法完成支付" } unless vip_user.can_pay?(amount, discounted: true)

    options = { direction: PointTransaction::CONSUME_IN, description: params[:subject], amount_source: get_amount_source, payment_type: VipUserTransaction::BY_BALANCE, order_no: out_trade_no, extra_remarks: body }
    vip_user.decrease_amount!(amount, "消费", options, discounted: true)

    render json: { errcode: 0, trade_no: vip_user.vip_user_transactions.last.try(:id).to_i }
  rescue => e
    logger.error "支付错误：#{e.message}，#{e.backtrace.join("\n")}"
    render json: { errcode: 1, errmsg: "支付错误：#{e.message}" }
  end

  # 赚取积分接口，输入参数：open_id, mp_user_open_id, points（积分）, description, source(来源，商品码将该参数设置为`winwemedia_spm`)
  # 赚取积分成功时，返回值 errcode为0
  def spm_points
    result = VipUser.increase_points_by_spm(params)
    render json: result
  end

  def spm_vip
    wx_mp_user = WxMpUser.where(openid: params[:mp_user_open_id]).first

    if params[:mp_user_open_id].present? && wx_mp_user
      redirect_to app_vips_url(site_id: wx_mp_user.site_id, openid: params[:open_id])
    else
      render json: { errcode: 40001, errmsg: "公众号不存在" }
    end
  end

  

  # 赚取积分接口，输入参数：open_id, mp_user_open_id, trade_token（会员表vip_users的字段）, amount（金额）, description, source(来源，电商将该参数设置为`winwemedia_ec`)
  # 赚取积分成功时，返回值 errcode为0
  def earn_points
    return render json: { errcode: 1, errmsg: "参数不正确，金额必须大于0" } if (amount = params[:amount].to_f) <= 0
    options = { direction: PointTransaction::CONSUME_IN, description: params[:description], amount_source: get_amount_source }
    points = @wx_mp_user.supplier.giving_points(amount, VipPrivilege::CONSUME, options, @vip_user)
    @vip_user.increase_points!(points)
    render json: { errcode: 0, points: points }
  end

  # 查看消费时可以获得多少积分及折扣后的价格的接口，输入参数:  open_id, mp_user_open_id, trade_token（会员表vip_users的字段）, amount
  # 成功时，返回： { errcode: 0, points: points }
  def earnable_points
    return render json: { errcode: 1, errmsg: "参数不正确，金额必须大于0" } if (amount = params[:amount].to_f) <= 0
    points          = @wx_mp_user.supplier.giving_points(amount, VipPrivilege::CONSUME, nil, @vip_user, pay: false)
    discount_amount = @vip_user.get_discounted_amount!(amount, VipPrivilege::CONSUME, nil, pay: false)
    render json: { errcode: 0, points: points, discount_amount: discount_amount }
  end

  # 查看@vip_user可用积分的接口，输入参数:  open_id, mp_user_open_id, trade_token
  def usable_points
    render json: { errcode: 0, points: @vip_user.usable_points }
  end

  # 扣除积分接口，输入参数: open_id, mp_user_open_id, trade_token, points, description, source(来源，电商将该参数设置为`winwemedia_ec`)
  # 积分扣除成功时，返回值 errcode为0
  def consume_points
    points = params[:points].to_i
    return render json: { errcode: 1, errmsg: "积分必须大于0" } if points <= 0
    return render json: { errcode: 1, errmsg: "积分不足" } unless @vip_user.decrease_points!(points)
    direction_type = {EC_SOURCE => PointTransaction::EC_PURCHASE, HOTEL_SOURCE => PointTransaction::HOTEL_PURCHASE}[params[:source]] || PointTransaction::OUT
    @vip_user.point_transactions.create supplier: @wx_mp_user.supplier, direction_type: direction_type, points: points, description: params[:description]
    render json: { errcode: 0 }
  end

  # 退还积分接口，输入参数: open_id, mp_user_open_id, trade_token, points, description, source(来源，电商将该参数设置为`winwemedia_ec`)
  # 积分退还成功时，返回值 errcode为0
  def return_points
    points = params[:points].to_i
    return render json: { errcode: 1, errmsg: "积分必须大于0" } if points <= 0
    @vip_user.increase_points!(points)
    direction_type = {EC_SOURCE => PointTransaction::EC_RETURN, HOTEL_SOURCE => PointTransaction::HOTEL_RETURN}[params[:source]] || PointTransaction::ADJUST_IN
    @vip_user.point_transactions.create supplier: @wx_mp_user.supplier, direction_type: direction_type, points: points, description: params[:description]
    render json: { errcode: 0 }
  end

  # 查询会员信息接口，输入参数: open_id, mp_user_open_id, trade_token
  # 成功时，返回值 errcode为0，及其它会员字段信息包括：user_no（会员卡号）、name（姓名）、mobile（手机号）、vip_grade_name（会员等级名称）、
  # usable_amount（可用余额）、usable_points（可用积分）
  # vip_privileges（会员可享受特权列表），包括：title（特权名称）、privilege（特权具体内容）、content（特权说明）
  def user_info
    render json: { errcode: 0, user_info: {
      user_no: @vip_user.user_no,
      name: @vip_user.name,
      mobile: @vip_user.mobile,
      vip_grade_name: @vip_user.vip_grade_name,
      usable_amount: @vip_user.usable_amount,
      usable_points: @vip_user.usable_points,
      vip_privileges: @vip_user.usable_privileges.map(&:privilege_json)
    } }
  end

  # 退还余额接口，输入参数: open_id, mp_user_open_id, trade_token, amount, description, source(来源，电商将该参数设置为`winwemedia_ec`)
  # 积分退还成功时，返回值 errcode为0
  def return_amount
    amount = params[:amount].to_f.round(2)
    return render json: {errcode: 1, errmsg: "金额必须大于0"} if amount <= 0
    VipUserTransaction.return_amount_to_vip_user!(@vip_user, amount, params)
    render json: { errcode: 0 }
  rescue => e
    logger.error "退还余额错误：#{e.message}，#{e.backtrace.join("\n")}"
    render json: { errcode: 1, errmsg: "退还余额错误：#{e.message}" }
  end

  private
    # 该方法会设置适当的参数，包括：wx_mp_user、supplier、vip_user
    def set_users
      open_id, mp_user_open_id, trade_token = params.values_at(:open_id, :mp_user_open_id, :trade_token)
      @wx_mp_user = WxMpUser.where(openid: mp_user_open_id).last
      @supplier   = @wx_mp_user.try(:supplier)
      render json: { errcode: 1, errmsg: "参数不正确，找不到公众账号" } and return false unless @wx_mp_user && @supplier
      @vip_user   = @wx_mp_user.vip_users.visible.where(trade_token: params[:trade_token]).last
      vip_checker = VipUserChecker.new(@vip_user, open_id)
      render json: { errcode: 1, errmsg: vip_checker.error_message } and return false if vip_checker.error?
    end
    
    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

    def get_amount_source
      sources = {
        EC_SOURCE => VipUserTransaction::EC_PAY_DOWN,
        HOTEL_SOURCE => VipUserTransaction::HOTEL_PAY_DOWN
      }
      sources[params[:source].to_s.strip] || VipUserTransaction::WEB_PAY_DOWN
    end

end
