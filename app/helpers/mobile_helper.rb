module MobileHelper
  include WxReplyMessage

  def mobile_index
    if @website
      mobile_root_url(id: @website.id, aid: session[:activity_id], openid: session[:openid], anchor: 'mp.weixin.qq.com')
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
      url = list_mobile_album_path(album.site_id, rel_id, openid: openid)
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
    if controller_name == 'bookings' && action_name == 'index'
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

  def website_activity_link(website_menu, options = {})
    openid = nil
    website = @website || website_menu.website

    @url = case website_menu.menu_type.to_i
      when 7 then return "tel:#{website_menu.tel}"
      when 6 then return website_menu.url
      when 2, 12, 13, 14, 15, 16, 19 then
        activity = website_menu.menuable
        return '' unless activity

        @wx_user ||= WxUser.where(openid: session[:openid]).first if session[:openid].present?
        openid = session[:openid]

        activity_notice = activity.activity_notices.active.first

        if activity.fight?
          url = app_fight_index_url(anid: activity_notice.id, aid: activity.id, openid: openid, m: 'index')
         elsif activity.activity_type.scene?
          url = mobile_scenes_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.reservation?
          url = mobile_reservations_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.govmail?
          url = mobile_govmails_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.govchat?
          url = mobile_govchats_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.broche?
          url = mobile_broche_photos_url(site_id: activity.site_id, aid: activity.id)
        elsif activity.house?
          url = app_house_layouts_url(aid: activity.id, openid: openid)
        elsif activity.house_bespeak?
          url = new_app_house_market_url(aid: activity.id, openid: openid)
        elsif activity.wbbs_community?
          url = mobile_wbbs_topics_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.ktv_order?
          url = app_ktv_orders_url(aid: activity.id, openid: openid)
        elsif activity.house_seller?
          url = app_house_sellers_url(aid: activity.id, openid: openid)
        elsif activity.house_intro?
          url = app_house_intros_url(aid: activity.id, openid: openid)
        #elsif activity.house_review?
        #  url = app_house_reviews_url(aid: activity.id, openid: openid)
        elsif activity.house_impression?
          url = app_house_impressions_url(aid: activity.id, openid: openid)
        elsif activity.house_live_photo?
          @wx_user.house_live_photos! #进入实景拍摄模式
          url = app_house_live_photos_url(aid: activity.id, openid: openid)
        elsif activity.vote?
          url = mobile_vote_login_url(site_id: activity.site_id, vote_id: activity.id, openid: openid)
        elsif activity.fans_game?
          url = mobile_fans_games_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.coupon?
          url = mobile_coupons_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.wave?
          url = mobile_waves_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.activity_type.unfold?
          url = mobile_unfolds_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.activity_type.recommend?
          if activity.wx_mp_user.authorized_auth_subscribe?
            url = mobile_recommends_url(site_id: activity.site_id, aid: activity.id)
          else
            url = mobile_recommends_url(site_id: activity.site_id, openid: openid, aid: activity.id)
          end
        elsif activity.activity_type.guess?
          url = mobile_guess_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.slot?
          url = app_slots_url(aid: activity.id, openid: openid)
        elsif activity.micro_aid?
          url = mobile_aids_url(activity_id: activity.id, site_id: activity.site_id, openid: openid)
        elsif activity.book_dinner?
          url = book_dinner_mobile_shops_url(site_id: activity.site_id, aid: activity.id,  openid: openid)
        elsif activity.book_table?
          url = book_table_mobile_shops_url(site_id: activity.site_id, aid: activity.id,  openid: openid)
        elsif activity.take_out?
          url = take_out_mobile_shops_url(site_id: activity.site_id, aid: activity.id,  openid: openid)
        elsif activity.micro_store?
          url = mobile_micro_stores_url(site_id: activity.site_id, openid: openid)
        elsif activity.enroll?
          url = new_app_activity_enroll_url(aid: activity.id, openid: openid)
        elsif activity.wshop? || activity.ec?
          url = wshop_root_url(wx_user_open_id: @wx_user.try(:openid), wx_mp_user_open_id: activity.wx_mp_user.try(:openid))
        elsif activity.website?
          url = mobile_root_url(site_id: activity.site_id, openid: openid)
        elsif activity.vip?
          vip_user = VipUser.where(user_id: @wx_user.try(:user_id)).first
          if @wx_user && @wx_user.wx_mp_user_id == activity.wx_mp_user_id
            if vip_user
              url = app_vips_url( openid: openid)
            else
              activity_notice = activity.activity_notices.ready.first
              return '' unless activity_notice
              url = app_vips_url( openid: openid)
            end
          else
            url = app_vips_url( wxmuid: activity.wx_mp_user_id)
          end
        elsif activity.hit_egg?
          url = app_hit_egg_url(activity_notice.activity, openid: openid, wxmuid: activity_notice.wx_mp_user_id)
        elsif activity.old_coupon?
          activity_notice = activity.activity_notices.first
          activity_consume = activity.activity_consumes.where(site_id: activity.site_id, wx_mp_user_id: activity.wx_mp_user_id, wx_user_id: @wx_user.try(:id)).first
          url = app_consume_url(id: activity_notice.id, code: activity_consume.try(:code), openid: openid, wxmuid: activity_notice.wx_mp_user_id)
        elsif activity.gua? and activity.setted?
          if [Activity::WARM_UP, Activity::HAS_ENDED].include?(activity.activity_status)
            activity_notice = activity.activity_notices.ready.first
          elsif activity.activity_status == Activity::UNDER_WAY
            activity_notice = activity.activity_notices.active.first
          end

          url = app_gua_url(id: activity.id, anid: activity_notice.try(:id), openid: openid, source: 'notice')
        elsif activity.wheel? and activity.setted?
          if activity.activity_status == Activity::WARM_UP
            activity_notice = activity.activity_notices.ready.first
          elsif activity.activity_status == Activity::UNDER_WAY
            activity_notice = activity.activity_notices.active.first
          end

          url = app_wheel_url(id: activity.id, anid: activity_notice.try(:id), openid: openid, source: 'notice')
        elsif activity.groups?
          url = app_activity_group_url(activity, openid: openid)
        elsif activity.group?
          #团购支付版
          url = mobile_groups_url(site_id: activity.site_id, openid: openid)
        elsif activity.vote?
          url = mobile_vote_login_url(site_id: activity.site_id, vote_id: activity.id, openid: openid)
        elsif activity.album?
          url = mobile_albums_url(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.panoramagram?
          if activity.activityable_type == "Panoramagram"
            url = panorama_mobile_panoramagram_url(site_id: activity.site_id, openid: openid, id: activity.activityable_id)
          else
            url = mobile_panoramagrams_url(site_id: activity.site_id, openid: openid, aid: activity.id)
          end
        elsif activity.booking?
          if BookingOrder.flow_suppliers.include?(activity.site_id)
            url = new_mobile_booking_order_path(site_id: activity.site_id)
          else
            url = mobile_bookings_url(site_id: activity.site_id, openid: openid)
          end
        elsif activity.wx_card?
          url = mobile_wx_cards_url(site_id: activity.site_id, openid: openid, aid: activity.id, wechat_card_js: 1)
        elsif activity.brokerage?
          url = mobile_brokerages_url(site_id: activity.site_id, openid: openid)
        elsif activity.red_packet?
          url = mobile_red_packets_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.surveys?
          url = mobile_survey_url(site_id: activity.site_id, id: activity.id, openid: openid)
        elsif activity.weddings?
          url = mobile_weddings_url(site_id: activity.site_id, openid: openid, wid: activity.activityable_id)
        elsif activity.message?
          url =  app_leaving_messages_url(aid: activity.id)
        elsif activity.educations?
          url = app_educations_url(cid: activity.activityable_id, openid: openid)
        elsif activity.hotel?
          url = "#{HOTEL_HOST}/wehotel-all/weixin/mobile/website.jsp?site_id=#{activity.site_id}&openid=#{openid}"
        elsif activity.oa?
          url = "#{OA_HOST}/woa-all/wx/#{activity.site_id}/index?openid=#{@wx_user.openid}"
        elsif activity.life?
          url = app_lives_url(id: activity.activityable_id, aid: activity.id, openid: openid)
        elsif activity.circle?
          url = app_business_circles_url(id: activity.activityable_id, aid: activity.id)
        elsif activity.donation?
          url = mobile_donations_url(site_id: activity.site_id, openid: openid, aid: activity.id)
        elsif activity.wmall?
          url = wmall_root_url(wx_user_open_id: openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), site_id: activity.supplier.id)
        elsif activity.wmall_coupon?
          url = wmall_coupon_url(wx_user_open_id: openid, wx_mp_user_open_id: activity.wx_mp_user.try(:openid), site_id: activity.supplier.id)
        elsif activity.business_shop?
          url = mobile_business_shop_url(activity.supplier, activity.activityable, openid: openid)
        elsif activity.trip?
          url = mobile_trips_url(site_id: activity.site_id, openid: openid)
        elsif activity.car?
          car_activity_notice = activity.activityable
          if car_activity_notice
            #if car_activity_notice.car_type?
            #  url = car_type_app_cars_url(aid: activity.id, openid: openid)
            if car_activity_notice.repair?
              url = car_bespeak_mobile_car_shops_url(site_id: activity.site_id, aid: activity.id, openid: openid, bespeak_type: CarBespeak::REPAIR)
            elsif car_activity_notice.test_drive?
              url = car_bespeak_mobile_car_shops_url(site_id: activity.site_id, aid: activity.id, openid: openid, bespeak_type: CarBespeak::TEST_DRIVE)
            elsif car_activity_notice.sales_rep?
              url = car_seller_mobile_car_shops_url(site_id: activity.site_id, aid: activity.id, openid: openid, seller_type: CarSeller::SALES_REP)
            #elsif car_activity_notice.sales_consultant?
            #  url = list_app_cars_url(aid: activity.id, openid: openid, seller_type: CarSeller::SALES_CONSULTANT)
            elsif car_activity_notice.shop?
              url = mobile_car_shops_url(site_id: activity.site_id, aid: activity.id, openid: openid)
            elsif car_activity_notice.owner?
              url = mobile_car_owners_url(site_id: activity.site_id, aid: activity.id, openid: openid)
            elsif car_activity_notice.assistant?
              url = mobile_car_assistants_url(site_id: activity.site_id, aid: activity.id, openid: openid)
            #else #default return shop type
            #  url = app_cars_url(aid: activity.id, openid: openid)
            end
          else
            url = ''
          end
        elsif activity.hospital?
          url = mobile_hospital_doctors_path(site_id: activity.site_id)
        elsif activity.plot_bulletin?
          url = bulletins_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.plot_repair?
          url = repair_complains_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid, type: 'repair')
        elsif activity.plot_complain?
          url = repair_complains_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid, type: 'complain')
        elsif activity.plot_telephone?
          url = telephones_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.plot_owner?
          url = owners_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid)
        elsif activity.plot_life?
          url = lives_mobile_wx_plots_path(site_id: activity.site_id, aid: activity.id, openid: openid)
        else
          url = ''
        end
        url = url.to_s + '#mp.weixin.qq.com'
        url

        # url = callback_api_index_url(url: url, openid: openid)
      when 3,1 then
        params =    website_menu.is_a?(WebsiteMenu)  ? {} : {popup_menu_id: website_menu.id}
        params = { website_picture_id: website_menu.id } if website_menu.is_a?(WebsitePicture)
        url = mobile_channel_url( {site_id: website.custom_domain, website_menu_id: website_menu.id, ext_name: nil}.merge(params) ) + "#mp.weixin.qq.com"
      when 8 then
        if website.try(:website_type) == 2
          url = page_app_life_url(website_menu.id)
        elsif website.try(:website_type) == 3
          url = page_app_business_circle_url(website_menu.id, wxmuid: session[:wx_mp_user_id])
        end
      when 10 then
        assistant = website_menu.menuable
        return '' unless assistant

        if assistant.try(:keyword) == "天气" && [3,4].include?(assistant.assistant_type)
          return life_assistant_weather_url(website_menu)
        elsif assistant.try(:keyword) == "公交" && [3,4].include?(assistant.assistant_type)
          return  life_assistant_bus_url(website_menu)
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
          #url = mobile_ec_carts_path(site_id: website_menu.menuable_id, openid: openid)
          #return url = wshop_cart_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
        elsif website_menu.menuable_type == 'Vip'
          #url = member_mobile_ec_shops_path(site_id: website_menu.menuable_id, openid: openid)
          #return url = wshop_wx_user_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
        elsif website_menu.menuable_type == 'HotelOrder'
          return "#{website_menu.url}#{@wx_user.try(:openid)}"
        else
          if website_menu.menuable_type.to_s == 'Activity'
            activity = website_menu.menuable
            return '' unless activity
            return url = wshop_root_url(wx_user_open_id: @wx_user.try(:openid), wx_mp_user_open_id: website.try(:supplier).try(:wx_mp_user).try(:openid))
          elsif website_menu.menuable_type.to_s == 'EcSellerCat'
            return url = wshop_category_url(category_id: website_menu.menuable_id, wx_mp_user_open_id: website.try(:supplier).try(:wx_mp_user).try(:openid), wx_user_open_id: @wx_user.try(:openid))
          elsif website_menu.menuable_type.to_s == 'EcItem'
            #url = mobile_ec_item_path(site_id: activity.site_id, id: website_menu.menuable_id, openid: openid)
            #return url = wshop_product_url(wx_user_open_id: wx_user.try(:openid), wx_mp_user_open_id: website_menu.menuable.wx_mp_user.try(:openid))
          end
        end

        return url = wshop_root_url(wx_user_open_id: @wx_user.try(:openid), wx_mp_user_open_id: website.try(:supplier).try(:wx_mp_user).try(:openid))
      when 21 then
        if website_menu.is_a?(WebsiteMenu)
          @wx_user = WxUser.where(openid: session[:openid]).first
          openid = @wx_user.openid if @wx_user
          url = list_mobile_album_url(site_id: website.site_id, aid: website_menu.menuable.try(:activity_id), openid: openid, id: website_menu.menuable_id)
        else
          "javascript:;"
        end
      when 22 then
        url = mobile_website_articles_url(site_id: website.site_id, article_type: 'as_article')
      when 23 then
        url = mobile_website_articles_url(site_id: website.site_id, article_type: 'as_product')
      else
        return "javascript:;"
    end
    @url.sub!(request.host_with_port, Settings.mhostname) if @url =~ %r[http://#{request.host_with_port}/]
    @url
  rescue => e
    return "javascript:;"
  end

  def menu_url child
    return unless child
    @website ||= child.website
    if ( child.class.to_s == 'Assistant' )
      child.url
    elsif (child.multiple_graphic? || child.has_children? || child.games?)
      child.class.to_s == 'WebsitePicture' ?
          mobile_channel_url(site_id: @website.custom_domain, website_menu_id: child.id, website_picture_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil) :
          mobile_channel_url(site_id: @website.custom_domain, website_menu_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif child.single_graphic?
      material_type_url child.try(:menuable), child
    elsif child.contact_by_qq? || child.mobile_qq?
      mobile_detail_url(site_id: @website.custom_domain, website_menu_id: child.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif child.audio_material?
      child.menuable.try(:audio_absolute_path)
      mobile_audio_url(site_id: @website.custom_domain, id: child.menuable.try(:id), ext_name: nil)
    else
      website_activity_link(child)
    end
  rescue => e
    return 'javascript:;'
  end

  def material_type_url material, menu
    return unless material

    if material.text?
      mobile_detail_url(site_id: menu.website.custom_domain, material_id: material.id, website_menu_id: menu.id, anchor: "mp.weixin.qq.com", ext_name: nil)
    elsif material.activity?
      material.menu_type = 2
      website_activity_link(material)
    else
      material.source_url
    end
  end

  def bqq_menu_url(child)
    if (Assistant === child)
      child.url
    elsif (child.multiple_graphic? || child.has_children? || child.games?)
      mobile_channel_url(site_id: child.website.custom_domain, website_menu_id: child.id, ext_name: nil)
    elsif child.audio_material?
      child.menuable.try(:audio_absolute_path)
    else
      website_activity_link(child)
    end
  end

  def get_website_menus(menus)
    return [] if menus.blank?

    data = []
    menus.each do |menu|
      next if menu.phone?
      data << { id: menu.id, name: menu.name, url: bqq_menu_url(menu), sub_menus: get_website_menus(menu.children) }
    end
    data
  end

  def judge_rich_text_present?(text)
    text = text.to_s.gsub(/\s/, '')
    text.present? && text.to_s != '<br>' && text.to_s != '<div><br></div>'
  end

end
