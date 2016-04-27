module MobileHelper
  include WxReplyMessage

  def mobile_index
    if @website
      mobile_root_url(site_id: @website.site_id, aid: session[:activity_id], openid: session[:openid], anchor: 'mp.weixin.qq.com')
    else
      ''
    end
  end

  def mobile_label_name_for(field)
    case field
    when 'mobile' then '电话'
    when 'name' then '姓名'
    when 'address' then '地址'
    when 'email' then '邮箱'
    end
  end

   def enroll_related_name(rel_type, rel_id)
    name = ''
    if rel_type == 'album'
      album =  Album.find_by_id(rel_id)
      name = album.try(:name)
    else
      activity = Activity.find_by_id(rel_id)
      name = activity.try(:name)
    end
    name = (name + ' >>') if name.present?
    name
  end

  def enroll_related_link(rel_type, rel_id, openid)
    url = ''
    if rel_type == 'album'
      album =  Album.find_by_id(rel_id)
      return url unless album
      url = list_mobile_album_url(album.site_id, rel_id, openid: openid)
    elsif  rel_type == 'website'
      activity = Activity.find_by_id(rel_id)
      return url unless activity
      url = mobile_root_url(site_id: activity.site_id, openid: openid)
    elsif  rel_type == 'scene'
      activity = Activity.find_by_id(rel_id)
      return url unless activity
      url = mobile_scenes_url(site_id: activity.site_id, aid: activity.id, openid: openid)
    end
    url
  end

  def cn_am_pm(time)
    return unless time

    time.hour < 12 ? "#{time.to_date} 上午" : "#{time.to_date} 下午"
  end

  def mobile_booking_body_class
    if controller_name == 'bookings' && ['index', 'show'].include?(action_name)
      'index'
    elsif controller_name == 'booking_categories' && action_name == 'show'
      'list'
    elsif controller_name == 'booking_items' && action_name == 'show'
      'detail'
    end
  end


  def get_star(star)
    stars = {1 => '很好', 2 => '好', 3 => '一般', 4 => '差' }
    stars[star] || '很好'
  end

  def vip_info_human_key( key )
    case key
    when 'card_no' then '卡号'
    else key
    end
  end

  def mobile_subdomain(site_id = nil)
    [site_id.to_s, MOBILE_SUB_DOMAIN].join('.')
  end

  def website_activity_link(website_menu, options = {})
    openid = nil
    website = @website || website_menu.website

    @url = case website_menu.menu_type.to_i
      when 7 then return "tel:#{website_menu.tel}"
      when 6 then return website_menu.url
      when 2, 12, 13, 14, 15, 16, 19 then
        activity = website_menu.menuable
        return '' unless activity

        activity_notice = activity.activity_notices.active.first

        url = activity.respond_mobile_url(activity_notice, openid: session[:openid])
        url = url.to_s + '#mp.weixin.qq.com'
        url

        # url = callback_api_index_url(url: url, openid: openid)
      when 3,1 then
        params =    website_menu.is_a?(WebsiteMenu)  ? {} : {popup_menu_id: website_menu.id}
        params = { website_picture_id: website_menu.id } if website_menu.is_a?(WebsitePicture)
        url = mobile_channel_url( {subdomain: mobile_subdomain(website.site_id), site_id: website.custom_domain, website_menu_id: website_menu.id, ext_name: nil}.merge(params) ) + "#mp.weixin.qq.com"
      when 8 then
        if website.try(:website_type) == 2
          url = page_app_life_url(website_menu.id)
        elsif website.try(:website_type) == 3
          url = page_app_business_circle_url(website_menu.id, subdomain: mobile_subdomain(website.site_id))
        end
      when 10 then
        assistant = website_menu.menuable
        return '' unless assistant

        if assistant.try(:keyword) == "天气" && [3,4].include?(assistant.assistant_type)
          return life_assistant_weather_url(website_menu)
        elsif assistant.try(:keyword) == "公交" && [3,4].include?(assistant.assistant_type)
          return  life_assistant_bus_url(website_menu, subdomain: mobile_subdomain(website.site_id))
        else
          return website_menu.try(:menuable).try(:url)
        end
      when 9 then
        return url = website_menu.try(:menuable).try(:url)
      when 11 then
        #return url = "http://api.map.baidu.com/geocoder?address=#{website_menu.address}&output=html"
        #return url = "http://map.baidu.com/mobile/webapp/search/search/qt=s&wd=#{website_menu.address}/vt=map"
        return url = "http://api.map.baidu.com/marker?location=#{website_menu.location_y},#{website_menu.location_x}&title=#{website_menu.address}&name=微枚迪&content=#{website_menu.address}&output=html&src=weiba|weiweb"
      when 17 then
        @wx_user = WxUser.where(openid: session[:openid]).first
        #return '' unless wx_user
        #业务对接
        if website_menu.menuable_type == 'EcCart'
          #url = mobile_ec_carts_url(site_id: website_menu.menuable_id, openid: openid)
          #return url = wshop_cart_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
        elsif website_menu.menuable_type == 'Vip'
          #url = member_mobile_ec_shops_url(site_id: website_menu.menuable_id, openid: openid)
          #return url = wshop_wx_user_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
        elsif website_menu.menuable_type == 'HotelOrder'
          return "#{website_menu.url}#{@wx_user.try(:openid)}"
        else
          if website_menu.menuable_type.to_s == 'Activity'
            activity = website_menu.menuable
            return '' unless activity
            return url = wshop_root_url(wx_user_open_id: @wx_user.try(:openid), wx_mp_user_open_id: website.try(:site).try(:wx_mp_user).try(:openid))
          elsif website_menu.menuable_type.to_s == 'EcSellerCat'
            return url = wshop_category_url(category_id: website_menu.menuable_id, wx_mp_user_open_id: website.try(:site).try(:wx_mp_user).try(:openid), wx_user_open_id: @wx_user.try(:openid))
          elsif website_menu.menuable_type.to_s == 'EcItem'
            #url = mobile_ec_item_url(site_id: activity.site_id, id: website_menu.menuable_id, openid: openid)
            #return url = wshop_product_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
          end
        end

        return url = wshop_root_url(wx_user_open_id: @wx_user.try(:openid), wx_mp_user_open_id: website.try(:site).try(:wx_mp_user).try(:openid))
      when 21 then
        if website_menu.is_a?(WebsiteMenu)
          @wx_user = WxUser.where(openid: session[:openid]).first
          openid = @wx_user.openid if @wx_user
          url = list_mobile_album_url(subdomain: mobile_subdomain(website.site_id), site_id: website.site_id, aid: website_menu.menuable.try(:activity_id), openid: openid, id: website_menu.menuable_id)
        else
          "javascript:;"
        end
      when 22 then
        url = mobile_website_articles_url(subdomain: mobile_subdomain(website.site_id), site_id: website.site_id, article_type: 'as_article')
      when 23 then
        url = mobile_website_articles_url(subdomain: mobile_subdomain(website.site_id), site_id: website.site_id, article_type: 'as_product')
      else
        return "javascript:;"
    end
    # @url.sub!(request.host_with_port, Settings.mhostname) if @url =~ %r[http://#{request.host_with_port}/]
    logger.info "************ url: #{@url}"
    @url
  # rescue => e
  #   return "javascript:;"
  end

  def menu_url child
    return unless child
    @website ||= child.website
    if ( child.class.to_s == 'Assistant' )
      child.url
    elsif (child.multiple_graphic? || child.has_children? || child.games?)
      child.class.to_s == 'WebsitePicture' ?
          mobile_channel_url(subdomain: mobile_subdomain(@website.site_id), site_id: @website.custom_domain, website_menu_id: child.id, website_picture_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil) :
          mobile_channel_url(subdomain: mobile_subdomain(@website.site_id), site_id: @website.custom_domain, website_menu_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif child.single_graphic?
      material_type_url child.try(:menuable), child
    elsif child.contact_by_qq? || child.mobile_qq?
      mobile_detail_url(subdomain: mobile_subdomain(@website.site_id), site_id: @website.custom_domain, website_menu_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif child.audio_material?
      child.menuable.try(:audio_absolute_path)
      mobile_audio_url(subdomain: mobile_subdomain(@website.site_id), site_id: @website.custom_domain, id: child.menuable.try(:id), ext_name: nil)
    else
      website_activity_link(child)
    end
  # rescue => e
  #   return 'javascript:;'
  end

  def material_type_url material, menu
    return unless material

    if material.text?
      mobile_detail_url(subdomain: mobile_subdomain(material.site_id), site_id: material.site_id, material_id: material.id, website_menu_id: menu.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif material.activity?
      material.menu_type = 2
      website_activity_link(material)
    else
      material.source_url
    end
  end

  def judge_rich_text_present?(text)
    text = text.to_s.gsub(/\s/, '')
    text.present? && text.to_s != '<br>' && text.to_s != '<div><br></div>'
  end

end
