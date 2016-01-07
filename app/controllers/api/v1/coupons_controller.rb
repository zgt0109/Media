class Api::V1::CouponsController < Api::BaseController
  before_filter :cors_set_access_control_headers

  before_filter :find_objects, except: [:recommend_coupons]

  # 优惠券接口

  def use
    return render json: { errcode: 1, errmsg: "验证未通过" } unless @coupon_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "参数不正确, 找不到公众账号" }  unless @wx_mp_user.is_a?(WxMpUser)

    @consume = @wx_mp_user.consumes.unused.unexpired.coupon_use_start.readonly(false).find_by_code(params[:code])
    return render json: { errcode: 1, errmsg: "SN码无效或已被使用" } unless @consume

    shop_branch = nil

    if @shop_branch.present?
      coupon = @consume.coupon
      if coupon.shop_branch_limited? && !coupon.shop_branch_ids.include?(@shop_branch.id )
        return render  json: {errcode: 1, errmsg: "此SN码不能在该门店使用"}
      end
    end

    @consume.use!(@shop_branch, params[:description])

    render json: { errcode: 0 }
  rescue => e
    logger.error "优惠券使用错误：#{e.message}, #{e.backtrace.join("\n")}"
    render json: { errcode: 1, errmsg: "优惠券使用错误：#{e.message}" }
  end

  def cancel
    return render json: { errcode: 1, errmsg: "验证未通过" } unless @coupon_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "参数不正确, 找不到公众账号" }  unless @wx_mp_user.is_a?(WxMpUser)

    @consume = @wx_mp_user.consumes.readonly(false).find_by_code(params[:code])
    return render json: { errcode: 1, errmsg: "SN码无效" } unless @consume

    @consume.cancel!(@shop_branch, params[:description])

    render json: { errcode: 0 }
  rescue => e
    logger.error "优惠券取消使用错误：#{e.message}, #{e.backtrace.join("\n")}"
    render json: { errcode: 1, errmsg: "优惠券取消使用错误：#{e.message}" }
  end

  # 查看微信用户获得的优惠券列表接口, 输入参数: open_id, mp_user_open_id, coupon_token
  def consume_list
    return render json: { errcode: 1, errmsg: "验证未通过" } unless @coupon_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "参数不正确, 找不到公众账号" } unless @wx_mp_user && @wx_mp_user.supplier

    if @wx_user.is_a?(WxUser)
      consumes = @wx_user.consumes.coupon.unused.unexpired.coupon_use_start.joins("join coupons on coupons.id = consumes.consumable_id AND consumes.consumable_type = 'Coupon'").select("consumes.consumable_type, consumes.consumable_id, consumes.code, consumes.expired_at, coupons.use_start as use_start,  coupons.value_by as value_by, coupons.value as value, coupons.qiniu_logo_key as qiniu_logo_key, coupons.name as name")
      if params[:value_by].present?
        consumes = consumes.where("coupons.value_by <= ? ", params[:value_by].to_f)
      end
      consumes = consumes.order('coupons.value DESC').as_json
      return render json: { errcode: 0, consumes: consumes }
    else
      return render json: { errcode: 1, errmsg: "微信用户不存在" }
    end
  end

   # 微客联盟推荐优惠券, 输入参数: city, industry, startNum, pageSize, coupon_token
  def recommend_coupons
    city, industry, page, per, coupon_token = params.values_at(:city, :industry, :startNum, :pageSize, :coupon_token)
    page = page.to_i + 1
    city = WxUser.sanitize(city)
    industry = WxUser.sanitize(industry) if industry.present?

    return render json: { errcode: 1, errmsg: "验证未通过" } unless coupon_token == 'AxJKl390nbYhd'

    tag_id = ActiveRecord::Base.connection.execute("select id from tags where name=#{city} limit 1").first.first
    recommended_ids = ActiveRecord::Base.connection.execute("select taggable_id from taggings where context='area' AND tag_id =#{tag_id} ").to_a.flatten.join(",")
    if industry.present?
      industry_wx_mp_user_open_ids = ActiveRecord::Base.connection.execute("select open_id from recommend_wx_mp_users where id in (#{recommended_ids}) AND industry =#{industry} AND has_activity = 1  AND enabled =1 ").to_a.flatten
    else
      industry_wx_mp_user_open_ids = ActiveRecord::Base.connection.execute("select open_id from recommend_wx_mp_users where id in (#{recommended_ids}) AND has_activity = 1  AND enabled =1 ").to_a.flatten
    end
    wx_mp_user_ids = WxMpUser.where(uid: industry_wx_mp_user_open_ids).pluck(:id)
    coupons = Coupon.mobile.can_apply.where(wx_mp_user_id: wx_mp_user_ids).order("created_at DESC").page(page).per(per)
    coupons = coupons.to_a.as_json.each do |coupon|
      object = Coupon.find_by_id(coupon['id'])
      wx_mp_user_open_id = object.wx_mp_user.try(:uid)
      coupon['wx_mp_user_open_id'] = wx_mp_user_open_id
      coupon['left_count'] = object.limit_count_avaliable - object.consumes.count
      coupon['left_days'] = (Date.today .. object.use_end.to_date).count
    end
    render json: { errcode: 0, coupons: coupons }
  end

  # 查看公众号下面优惠券列表接口, 输入参数: open_id, mp_user_open_id, coupon_token
  def coupon_list
    return render json: { errcode: 1, errmsg: "验证未通过" } unless @coupon_token == 'AxJKl390nbYhd'
    return render json: { errcode: 1, errmsg: "参数不正确, 找不到公众账号" } unless @wx_mp_user && @wx_mp_user.supplier

    activity = @wx_mp_user.activities.coupon.show.first
    return render json: { errcode: 1, errmsg: "该公众号下没有优惠券" } unless activity

    coupons = activity.coupons.mobile.can_apply
    if params[:value_by].present?
      coupons = coupons.where("value_by <= ? ", params[:value_by].to_f)
    end
    coupons = coupons.order("value DESC").as_json.each do |coupon|
      object = Coupon.find_by_id(coupon['id'])
      wx_mp_user_open_id = object.wx_mp_user.try(:uid)
      coupon['wx_mp_user_open_id'] = wx_mp_user_open_id
      coupon['left_count'] = object.limit_count_avaliable - object.consumes.count
      coupon['left_days'] = (Date.today .. object.use_end.to_date).count
    end
    render json: { errcode: 0, coupons: coupons }
  end

  private
    def find_objects
      open_id, shop_branch_id, wx_mp_user_open_id, @coupon_token, code = params.values_at(:open_id, :shop_branch_id, :wx_mp_user_open_id, :coupon_token, :code)

      @wx_mp_user = WxMpUser.where(uid: wx_mp_user_open_id).first
      @wx_user = @wx_mp_user.wx_users.find_by_uid(open_id)
      @shop_branch = ShopBranch.find_by_id(shop_branch_id)
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

end
