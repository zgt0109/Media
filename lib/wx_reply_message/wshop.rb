module WxReplyMessage
  def wshop_api_categories(options={})
    category_id = options[:category_id]
    wx_mp_user_open_id = options[:wx_mp_user_open_id]
    HTTParty.get "#{WSHOP_HOST}/api/categories/winwemedia_selects.json?wx_mp_user_id=#{wx_mp_user_open_id}&category_id=#{category_id}"
    #HTTParty.get "http://ec.testing.winwemedia.com/api/categories/winwemedia_selects.json?wx_mp_user_id=gh_d4e97b5b5921&category_id=#{category_id}"

    #[
    #    [22, [{id: 11,name: "x"},{id: 22,name: 'xx'}]],
    #    [222, [{id: 222,name: 'xxx'}]]
    #]
  rescue
    nil
  end

  def wshop_root_url(options={})
    wx_user_open_id, wx_mp_user_open_id = options[:wx_user_open_id], options[:wx_mp_user_open_id]
    "#{WSHOP_HOST}/mobile/shops/s?wx_user_id=#{wx_user_open_id}&wx_mp_user_id=#{wx_mp_user_open_id}"
  end

  def wshop_cart_url(options={})
    wx_user_open_id, wx_mp_user_open_id = options[:wx_user_open_id], options[:wx_mp_user_open_id]
    "#{WSHOP_HOST}/mobile/carts/current?wx_user_id=#{wx_user_open_id}&wx_mp_user_id=#{wx_mp_user_open_id}"
  end

  def wshop_wx_user_url(options={})
    wx_user_open_id, wx_mp_user_open_id = options[:wx_user_open_id], options[:wx_mp_user_open_id]
    "#{WSHOP_HOST}/mobile/wx_users/s?wx_user_id=#{wx_user_open_id}&wx_mp_user_id=#{wx_mp_user_open_id}"
  end

  def wshop_product_url(options={})
    wx_user_open_id, wx_mp_user_open_id = options[:wx_user_open_id], options[:wx_mp_user_open_id]
    "#{WSHOP_HOST}/mobile/shops/s?wx_user_id=#{wx_user_open_id}&wx_mp_user_id=#{wx_mp_user_open_id}"
  end

  def wshop_category_url(options={})
    wx_user_open_id, wx_mp_user_open_id = options[:wx_user_open_id], options[:wx_mp_user_open_id]
    category_id = options[:category_id]
    "#{WSHOP_HOST}/mobile/products?category_id=#{category_id}&wx_user_id=#{wx_user_open_id}&wx_mp_user_id=#{wx_mp_user_open_id}"
  end

  def wshop_admin_root_url(auth_token=nil)
    # "#{WSHOP_HOST}/admin/site/wx_settings?auth_token=#{auth_token}"
    "#{WSHOP_HOST}/admin/site/wx_settings?encrypted_auth_token=#{auth_token}"
  end
end
