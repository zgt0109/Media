module ApiWeixinControllerHelper

  def custom_subdomain(site_id = nil)
    [site_id.to_s, MOBILE_SUB_DOMAIN].join('.')
  end

  def weixin_news_item_for_material(material, options = {})
    pic_url  = qiniu_image_url(material.pic_key)
    url      = url_for_material(material, options)
    {title: material.title, description: material.summary, pic_url: pic_url, url: url}
  end

  def url_for_material(material, options = {})
    if material.activity?
      material.materialable.respond_mobile_url(nil, openid: options[:openid])
    elsif material.link?
      material.source_url
    else
      "#{app_material_url(material, subdomain: mobile_subdomain(material.site_id))}#mp.weixin.qq.com"
    end
  end

  def respond_wmall_activity(from_user_name, to_user_name, qrcodeable)
    url = wmall_shop_url({shop_id: qrcodeable.id, wx_user_open_id: from_user_name, wx_mp_user_open_id: to_user_name, site_id: qrcodeable.try(:mall).try(:site_id)})
    activity = Activity.where(activity_type_id: 54,activityable_type:"Wmall::Shop", activityable_id: qrcodeable.id).first
    pic_url = (activity && activity.pic_key.present?) ? activity.qiniu_pic_url_for_wmall : qrcodeable.pic_url
    items = [{title: qrcodeable.name, description: qrcodeable.description, pic_url: pic_url , url: url}]
    @echostr = Weixin.respond_news(from_user_name, to_user_name, items)
  end

  def respond_wmall_ec_good(from_user_name, to_user_name, qrcodeable)
    url = wmall_ec_good_url({ec_good_id: qrcodeable.id, wx_user_open_id: from_user_name, wx_mp_user_open_id: to_user_name, site_id: qrcodeable.try(:mall).try(:site_id)})
    pic_url = Wmall::EcGoodPicture.where(goods_id: qrcodeable.id, status: 1).first.qiniu_pic_url
    items = [{title: qrcodeable.name, description: "", pic_url: pic_url, url: url}]
    @echostr = Weixin.respond_news(from_user_name, to_user_name, items)
  end

  def respond_wmall_ec_coupon(from_user_name, to_user_name, qrcodeable)
    url = detail_wmall_coupon_url({coupon_id: qrcodeable.id, wx_user_open_id: from_user_name, wx_mp_user_open_id: to_user_name, site_id: qrcodeable.try(:shop).try(:mall).try(:site_id)})
    pic_url = qrcodeable.pictures.first.qiniu_pic_url
    items = [{title: qrcodeable.name, description: "", pic_url: pic_url, url: url}]
    @echostr = Weixin.respond_news(from_user_name, to_user_name, items)
  end

  def respond_wmall_ec_group_good(from_user_name, to_user_name, qrcodeable)
    url = detail_wmall_group_url({group_id: qrcodeable.id, wx_user_open_id: from_user_name, wx_mp_user_open_id: to_user_name, site_id: qrcodeable.try(:shop).try(:mall).try(:site_id)})
    pic_url = Wmall::GroupPicture.where(goods_id: qrcodeable.id).first.qiniu_pic_url
    items = [{title: qrcodeable.group_name, description: "", pic_url: pic_url, url: url}]
    @echostr = Weixin.respond_news(from_user_name, to_user_name, items)
  end

end