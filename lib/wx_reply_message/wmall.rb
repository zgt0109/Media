module WxReplyMessage
  def wmall_root_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/mall/index?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wlife-unified/wx/mall/index?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def wmall_shop_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    shop_id = options[:shop_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/wxshop/toShopDetail?shopId=#{shop_id}&wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wlife-unified/wx/wxshop/toShopDetail?shopId=#{shop_id}&wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def wmall_ec_good_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    ec_good_id = options[:ec_good_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/business/gotoproductdetail/#{ec_good_id}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wx/business/gotoproductdetail/#{ec_good_id}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def wmall_coupon_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/coupon/mallcoupons?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wlife-unified/wx/coupon/mallcoupons?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def detail_wmall_coupon_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/coupon/couponId=#{options[:coupon_id]}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wlife-unified/wx/coupon/couponId=#{options[:coupon_id]}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def detail_wmall_group_url(options={})
    wx_user_open_id, wx_mp_user_open_id, supplier_id = options[:wx_user_open_id], options[:wx_mp_user_open_id], options[:supplier_id]
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/wx/gotogroupdetail/#{options[:group_id]}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    else
      "#{WMALL_HOST}/wlife-unified/wx/gotogroupdetail/#{options[:group_id]}?wx_user_open_id=#{wx_user_open_id}&wx_mp_user_open_id=#{wx_mp_user_open_id}&supplier_id=#{supplier_id}"
    end
  end

  def wmall_admin_root_url(auth_token=nil, supplier_id=nil)
    # "#{WMALL_HOST}/admin/malls?auth_token=#{auth_token}"
    if Rails.env.production?
      "#{custom_wmall_host(supplier_id)}/mall/login?auth_token=#{auth_token}"
    else
      "#{WMALL_HOST}/wlife-unified/mall/login?auth_token=#{auth_token}"
    end
  end

  def custom_wmall_host(supplier_id=nil)
    supplier_id == 79750 ? 'http://calxon.life.winwemedia.com' : WMALL_HOST
  end

end

