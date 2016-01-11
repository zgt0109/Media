# -*- coding: utf-8 -*-
module ApplicationHelper
  include WxReplyMessage

  def render_progress_bar(width =  0)
    "<div class='progress' data-percent='#{width}%'><div class='progress-bar' style='width:#{width}%;height:20px;'><span style='display: none'>#{width}%</span></div></div>".html_safe
  end

  def modal_to(name = "弹窗样例", url = "/", options = {})
    options[:title] ||= name.include?('<') && "Modal Window" || name
    options[:height] ||= 800
    options["data-toggle"] = "modals"
    options["data-iframe"] = url
    options["data-title"] ||= options.delete(:title)
    options["data-width"] ||= options.delete(:width)
    options["data-height"] ||= options.delete(:height)
    options[:title] = options[:tip]
    link_to(name, "javascript:;", options)
  end

  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def meta_keywords(meta_keywords)
    content_for(:meta_keywords){ meta_keywords.to_s }
  end

  def meta_description(meta_description)
    content_for(:meta_description){ meta_description.to_s }
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def f(double, options = {})
    number_with_precision( double.to_f, { :precision => 2 }.merge(options) )
  end

  def hide_for_temp_user
    session[:account_id] == TEST_USER_ID ? "style='display:none'".html_safe : ""
  end


  def options_for_date(options = {})
    dates = []
    start_date = (options[:start_date].present? ? Date.parse(options[:start_date]) : nil) || Date.today
    end_date = (options[:end_date].present? ? Date.parse(options[:end_date]) : nil) || (options[:days_after_today].present? ? Date.today+options[:days_after_today].to_i.days : nil) || (options[:days_after_start_date].present? ? start_date+options[:days_after_start_date].to_i.days : nil) || start_date+91.days
    (start_date .. end_date).each do |p|
      dates.push([p.strftime((options[:format].present? ? options[:format] : "%m月%d日")), p])
    end
    options_for_select(dates, (options[:selected].present? ? options[:selected] : Date.today))
  end

  def date_for_select(name = '', options = {})
    html = ''
    html << select_tag(name, options_for_date(options), id: options[:id], class: options[:class])
    html.html_safe
  end

  def options_for_months(options = {})
    month_count = 11
    months = []
    current_month_first_day = Date.today.beginning_of_month
    (0 .. month_count).each do |m|
      month_first_day = current_month_first_day.ago(m.month).beginning_of_month
      months.push([month_first_day.strftime((options[:format].present? ? options[:format] : "%Y年%m月")), month_first_day.to_date])
    end
    options_for_select(months, (options[:selected].present? ? options[:selected] : current_month_first_day.to_date))
  end

  def months_for_select(name = '', options = {})
    html = ''
    html << select_tag(name, options_for_months(options), id: options[:id], class: options[:class], style: options[:style])
    html.html_safe
  end

  def options_for_province(selected = 9)
    options_for_select(Province.pluck(:name, :id), selected.to_i)
  end

  def options_for_city(province_id = 9, city_id = 73)
    province = Province.where(id: province_id).first
    if province
      cities = province.cities
      options_for_select(cities.pluck(:name, :id), city_id.to_i)
    else
      options_for_select([['上海市', 73]])
    end
  end

  def options_for_district(city_id = 73, district_id = 702, options={})
    if city_id.blank?
      if options[:province_id]
        options_for_select([['', '']])
      else
        options_for_select([['黄浦区', 702]])
      end
    else
      districts = City.find(city_id).districts
      options_for_select(districts.pluck(:name, :id), district_id.to_i)
    end
  end

  def address_select(model, options = {})
    name_prefix       = options.delete(:name_prefix) || model.class.to_s.underscore
    district_options  = options.delete(:district_options) || {}
    no_city, no_district = options.delete(:no_city), options.delete(:no_district)
    select_gap = options.key?(:select_gap) ? options.delete(:select_gap).to_s : ' '

    model.province_id ||= 9
    model.city_id     ||= 73
    model.district_id ||= 702 if model.respond_to?(:district_id)

    html = select_tag("#{name_prefix}[province_id]", options_for_province(model.province_id), options.merge(id: 'province') )
    unless no_city
      html << select_gap
      html << select_tag("#{name_prefix}[city_id]", options_for_city(model.province_id, model.city_id), options.merge(id: 'city') )
    end
    unless no_district
      html << select_gap
      html << select_tag("#{name_prefix}[district_id]", options_for_district(model.city_id, model.district_id, district_options), options.merge(id: 'district') )
    end
    html.html_safe
  end

  def options_for_car_brand(brand_id = 0)
    if brand_id.blank?
      options_for_select([['', '']])
    else
      # car_brands = (@supplier||current_user).car_brands.normal
      car_brands = [(@supplier||current_user).car_brand]
      options_for_select(car_brands.collect{ |b| [b.name, b.id] }, brand_id.to_i)
    end
  end

  def car_brand_select(brand_id = 0)
    html = ''
    html << select_tag("car_type[car_brand_id]", options_for_car_brand(brand_id), id: 'car_brand')
    html.html_safe
  end

  def car_brand_select_for_car_bespeak(brand_id = 0)
    html = ''
    html << select_tag("car_bespeak[car_brand_id]", options_for_car_brand(brand_id), id: 'bespeak_car_brand')
    html.html_safe
  end

  def options_for_car_catena(brand_id = 0 ,catena_id = 0)
    if brand_id.blank?
      options_for_select([['', '']])
    else
      car_catenas = (@supplier||current_user).car_brand.car_catenas.normal
      options_for_select(car_catenas.pluck(:name, :id), catena_id.to_i)
    end
  end

  def car_catena_select(brand_id = 0 ,catena_id = 0)
    html = ''
    html << select_tag("car_type[car_catena_id]", options_for_car_catena(brand_id, catena_id), id: 'car_catena')
    html.html_safe
  end

  def car_catena_select_for_mobile_car_type(brand_id = 0 ,catena_id)
    html = ''
    html << select_tag("car_type[car_catena_id]", options_for_car_catena(brand_id, catena_id), include_blank: '', id: 'car_catena')
    html.html_safe
  end

  def options_for_car_type(type_id = 0)
    car_types = @car_shop.car_types.normal
    options_for_select(car_types.collect{ |t| ["#{t.car_brand.try(:name)} - #{t.car_catena.try(:name)} - #{t.name}", t.id] }, type_id.to_i)
  end

  def car_type_select_for_car_picture(type_id = 0)
    html = ''
    html << select_tag("car_picture[car_type_id]", options_for_car_type(type_id), include_blank: '', id: 'car_type')
    html.html_safe
  end

  def options_for_car_catena_for_car_pictures(catena_id = 0)
    car_catenas = @car_shop.car_catenas.normal.includes(:car_brand).where("car_brands.status = ?", CarBrand::NORMAL)
    options_for_select(car_catenas.collect{ |t| ["#{t.car_brand.try(:name)} - #{t.name}", t.id] }, catena_id.to_i)
  end

  def car_catena_select_for_car_picture(catena_id = 0)
    html = ''
    html << select_tag("car_picture[car_catena_id]", options_for_car_catena_for_car_pictures(catena_id), id: 'car_catena')
    html.html_safe
  end

  def options_for_car_catena_type_for_bespeak(brand_id, type_id)
    if brand_id.blank?
      options_for_select([['', '']])
    else
      if type_id.blank?
        # car_types = @car_shop.car_brands.normal.first.try(:car_types)
        car_types = @car_shop.car_brand.try(:car_types)
      else
        car_types = @car_shop.car_types.normal.where(id: type_id).first.try(:car_brand).try(:car_types)
      end
      options_for_select(car_types.collect{ |t| ["#{t.car_catena.try(:name)} - #{t.name}", t.id] }, type_id.to_i)
    end
  end

  def car_type_select_for_car_bespeak(brand_id, type_id = 0)
    html = ''
    if type_id.blank?
      options_for_select([['', '']])
    else
     html << select_tag("car_bespeak[car_type_id]", options_for_car_catena_type_for_bespeak(brand_id, type_id), id: 'bespeak_car_type')
     html.html_safe
    end
  end

  def car_catena_select_for_car_bespeak(brand_id = 0 ,catena_id = 0)
    html = ''
    html << select_tag("car_bespeak[car_catena_id]", options_for_car_catena(brand_id, catena_id), id: 'car_catena')
    html.html_safe
  end

  def options_for_room_type(action_type, branch_id, room_type_id)
    if branch_id.blank?
      options_for_select([['', '']])
    else
      hotel_room_types = @hotel.hotel_room_types.normal.where(hotel_branch_id: branch_id.try(:to_i)).order('created_at desc')
      options_for_select(hotel_room_types.pluck(:name, :id), room_type_id.try(:to_i))
    end
  end

  def options_for_system_custom_fields
    options_for_select(CustomField.system_options.collect{ |k,v| [k, k, {'data-format'=> v.fetch('format'), 'data-values' => v.fetch('values')}]})
  end

  def options_for_custom_custom_fields
    options_for_select(CustomField.custom_options.collect{ |k,v| [k, k, {'data-format'=> v.fetch('format'), 'data-values' => v.fetch('values')}]})
  end

  def hotel_branch_select(action_type, branch_id, room_type_id)
    html = ''
    html << select_tag("#{action_type}[hotel_branch_id]", options_for_select(@hotel.hotel_branches.normal.pluck(:name, :id), branch_id.try(:to_i)), id: 'hotel_branch', class: 'col-xs-5')
    html << ' '
    # html << select_tag("#{action_type}[hotel_room_type_id]", options_for_room_type(action_type, branch_id, room_type_id), include_blank: '全部', id: 'hotel_room_type')
    html.html_safe
  end

  def supplier_categories_for_js
    supplier_categories = ''

    AccountCategory.root.includes(:children).each do |category|
      children = category.children.collect {|child| "['#{child.name}', #{child.id.to_i}]"}
      supplier_categories << "#{category.id.to_i}: [#{children.join(', ')}],"
    end

    html = content_tag(:script, "var supplier_categories = { #{supplier_categories.sub!(/,$/, "")} };")
    raw html.html_safe.gsub!(/&#x27;/, "'")
  end

  def areas_for_js
    areas = ''

    Province.includes(:cities).order(:id).each do |province|
      cities = province.cities.collect {|city| "['#{city.name}', #{city.id.to_i}]"}
      areas << "#{province.id.to_i}: [#{cities.join(', ')}],"
    end

    html = content_tag(:script, "var areas = { #{areas.sub!(/,$/, "")} };")
    raw html.html_safe.gsub!(/&#x27;/, "'")
  end


  def leaving_message_admin_path
    if current_site.activities.setted.message.exists?
      leaving_messages_url
    else
      edit_activity_leaving_messages_url
    end
  end

  def hotel_branches_for_js
    hotel_branches = ''

    @hotel.hotel_branches.normal.each do |branch|
      hotel_room_types = branch.hotel_room_types.normal.collect {|room_type| "['#{room_type.name}', #{room_type.id.to_i}]"}
      hotel_branches << "#{branch.id.to_i}: [#{hotel_room_types.join(', ')}],"
    end

    html = content_tag(:script, "var hotel_branches = { #{hotel_branches.sub!(/,$/, "")} };")
    raw html.html_safe.gsub!(/&#x27;/, "'")
  end

  def car_brands_for_js(options = {})
    car_brands = ''
    logger.info "1111111#{(@supplier||current_user).id}"
    [(@supplier||current_user).car_brand].each do |brand|
      car_catenas = brand.car_catenas.normal.collect {|catena| "['#{catena.name}', #{catena.id.to_i}]"}
      car_catenas.unshift("['','']") if "mobile_car_type".eql?(options[:source])
      car_brands << "#{brand.id.to_i}: [#{car_catenas.join(', ')}],"
    end

    html = content_tag(:script, "var car_brands = { #{car_brands.sub!(/,$/, "")} };")
    raw html.html_safe.gsub!(/&#x27;/, "'")
  end

  def bespeak_car_brands_for_js
    car_brands = ''

    [(@supplier||current_user).car_brand].each do |brand|
      car_types = brand.car_types.normal.collect {|type| "['#{type.car_catena.try(:name)} - #{type.name}', #{type.id.to_i}]"}
      car_brands << "#{brand.id.to_i}: [#{car_types.join(', ')}],"
    end

    html = content_tag(:script, "var car_brands = { #{car_brands.sub!(/,$/, "")} };")
    raw html.html_safe.gsub!(/&#x27;/, "'")
  end

  # options: ip,ak,coor
  def current_location(options = {})
    result = RestClient.get("http://api.map.baidu.com/location/ip?ak=9c72e3ee80443243eb9d61bebeed1735&coor=bd09ll")
    info = JSON(result)
    # puts info
  end

  def get_location
    current_location[]
  end

  def first_or_last i
    ret = ''
    ret = "first" if (i+1) % 3 == 1
    ret = "last" if (i+1) % 3 == 0
    return ret
  end

  # add by xy 2013-10-09
  # 微调研显示title
  def show_title_for_surveys
     if params[:controller] == "app/surveys"
       if params[:action] == "index"
         return @activity.try(:name)
       elsif params[:action] == "new"
         return "请先填写您的资料"
       elsif params[:action] == "show"
         return "答题"

       elsif params[:action] == "fedback"
         return @activity.try(:name)
       elsif params[:action] == "success"
         return @activity.try(:name)
       end
      end
  end

  def show_activity_status activity
    if activity.operation? || activity.wave?
      activity.activity_status_name
    elsif activity.activity_type.is_show?
      if activity.old_coupon? && activity.starting?
        gua_status_name(activity)
      elsif activity.vote?
        activity.activity_status_name
      else
        if activity.setted?
          activity.activity_status_name
        else
          activity.status_name
        end
      end
    else
      ""
    end
  end

  def gua_status_name(activity)
    if activity.activity_consumes.count < activity.activity_property.coupon_count
      '进行中'
    else
      '券已领完'
    end
  end

  def show_disable_with_input
    if @wedding_guest.present?
      return true
    else
      return false
    end
  end

  def show_current_class controller, action
    if params[:controller] == controller && action.include?(params[:action])
      return "current"
    else
      return ''
    end
  end

  def website_activity_link_to_url(website_menu, options = {})
    url = website_activity_link(website_menu)
    if website_menu.menu_type.to_i == 7 || website_menu.menu_type.to_i == 6
      return  url
    else
      return url + "#mp.weixin.qq.com"
    end
  end

  def life_assistant_weather_url(website_menu)
    flag = true
    url = ''
    Assistant::WEATHERCITY.select do |w|
      if website_menu.website.city_id == w[0].to_i
        url = "#{website_menu.try(:menuable).try(:url)}/#{w[1]}"
        flag = false
        break
      end
    end
    url = "#{website_menu.try(:menuable).try(:url)}/#{website_menu.try(:website).try(:city).try(:pinyin)}" if flag
    return url
  end

  def life_assistant_bus_url(website_menu)
    flag = true
    url = ''
    Assistant::TRAINCITY.select do |w|
      if website_menu.website.city_id == w[0].to_i
        url = "#{website_menu.try(:menuable).try(:url)}/#{w[1]}_bus"
        flag = false
        break
      end
    end
    url = "#{website_menu.try(:menuable).try(:url)}/#{website_menu.try(:website).try(:city).try(:pinyin)}_bus" if flag
    return url
  end

  def show_class_with_website
    if controller_path == "app/websites" || controller_path == "mobile/websites"
      if action_name == "show"
        return "list" if @website.template16?
        return "index"
      elsif action_name == "page"
        if @website_menu && (@website_menu.has_children? or @website_menu.website.try(:template11?))
          return "list"
        else
          return "article"
        end
      end
    end
  end

  def show_app_website_footer
      if [9, 12, 13, 14, 16].include?(@website.template_id)
        ""
      elsif @website.template8?
        if action_name == "show"
          render :partial => "app_footer"
        else
          return ''
        end
      elsif @website.template6?
        if action_name == "show"
          render :partial => "application/app_footer_template6"
        else
          if @website_menu.single_graphic?
            render :partial => "application/app_footer"
          else
            render :partial => "application/app_footer_template6"
          end
        end
      else
        if action_name == "show"
          if [5, 7, 15].include?(@website.template_id)
            return ""
          else
            render :partial => "application/app_footer"
          end
        else
          render :partial => "application/app_footer"
        end
      end
  end

  def show_app_website_btn_up
    if @website.template6?
      if action_name == "show"
        ""
      else
        if @website_menu.single_graphic?
          return '<a href="javascript:;" class="btn-up"></a>'.html_safe
        else
          return ""
        end
      end
    else
      if action_name == "show"
        if [5, 7, 8, 9, 10, 12].include?(@website.template_id)
          return ""
        else
          return '<a href="javascript:;" class="btn-up"></a>'.html_safe
        end
      else
        return '<a href="javascript:;" class="btn-up"></a>'.html_safe
      end
    end
  end

  def show_app_website_plug_phone
    if @website.template6?
      if action_name == "show"
        return ""
      else
        if @website_menu.single_graphic?
          render :partial=> "app_plug_phone", :locals => {:website_popup_menus => @website_popup_menus}
        else
          return ""
        end
      end
    elsif @website.template12?
      if action_name == "show"
        render :partial=> "app_plug_phone", :locals => {:website_popup_menus => @website_popup_menus}
      else
        return ""
      end
    elsif @website.template14? or @website.template15?
      return ""
    else
      if action_name == "show"
        if [5, 7, 8, 9, 10, 13].include?(@website.template_id)
          return ""
        else
          render :partial=> "app_plug_phone", :locals => {:website_popup_menus => @website_popup_menus}
        end
      else
        render :partial=> "app_plug_phone", :locals => {:website_popup_menus => @website_popup_menus}
      end
    end
  end

  def pro_website_picture_size website
    if [5, 6, 7, 8, 9, 10, 12].include?(website.website_setting.try(:home_template_id))
      "图片建议尺寸：640像素*1136像素，可支持上传格式为：jpg、png、bmp、gif；"
    elsif [1, 2, 3, 4, 11, 13, 14].include?(website.website_setting.try(:home_template_id))
      "图片建议尺寸：720像素*400像素，可支持上传格式为：jpg、png、bmp、gif；"
    else
      '此模板不支持首页轮播图'
    end
  end


  def pro_website_picture website
    if [5, 6, 7, 8, 9, 10, 12].include?(website.website_setting.try(:home_template_id))
      [640, 1136]
    elsif [1, 2, 3, 4, 11, 13, 14].include?(website.website_setting.try(:home_template_id))
      [720, 400]
    else
      []
    end
  end

  def website_article_with_layer_show website_menus = nil
     arr = []
     website_menus = website_menus.article.where('website_menus.parent_id > 0')
     website_menus.each do |website_menu|
       arr << [website_menu.com_str([website_menu.name]), website_menu.id] unless website_menu.has_children?
     end
     arr
  end

  def redirect_back_life_or_circle_to_page
    if @website.website_type == 2
      if @website_menu.present? && @website_menu.parent.present? && @website_menu.parent.parent_id != 0
        page_app_life_url(id:@website_menu.parent.id, anchor: "mp.weixin.qq.com")
      else
        app_lives_url(id: @website.id, anchor: "mp.weixin.qq.com")
      end
    elsif @website.website_type == 3
      if @website_menu.present? && @website_menu.parent.present? && @website_menu.parent.parent_id != 0
        page_app_business_circle_url(id:@website_menu.parent.id, anchor: "mp.weixin.qq.com", wxmuid: session[:wx_mp_user_id])
      else
        app_business_circles_url(id:@website.id, anchor: "mp.weixin.qq.com", wxmuid: session[:wx_mp_user_id])
      end
    end
  end

  def website_article_toggle_recommend_path(website_article)
    return "/pro/website_articles/#{website_article.id}/toggle_recommend" if website_article.website.micro_life?
    return "/busine_articles/#{website_article.id}/toggle_recommend" if website_article.website.micro_circle?
  end

  def require_ec_ad_link picture
    if picture.category?
      mobile_ec_category_path(supplier_id: @supplier.id, id: picture.menuable_id)
    elsif picture.product?
      mobile_ec_item_path(supplier_id: @supplier.id, id: picture.menuable_id, anchor: "mp.weixin.qq.com")
    else
      website_activity_link(picture)
    end
  end

  def website_article_toggle_recommend_path(website_article)
    return "/pro/website_articles/#{website_article.id}/toggle_recommend" if website_article.website.micro_life?
    return "/busine_articles/#{website_article.id}/toggle_recommend" if website_article.website.micro_circle?
  end


  def quick_link_options
    {
      '请选择'     => '',
      "积分换礼品"   => "http://#{Settings.mhostname}/app/vips/gifts?wxmuid=#{current_site.wx_mp_user.try(:id)}",
      "会员签到"    => "http://#{Settings.mhostname}/app/vips/signin?wxmuid=#{current_site.wx_mp_user.try(:id)}",
      "会员卡套餐"   => "http://#{Settings.mhostname}/app/vips/vip_packages?wxmuid=#{current_site.wx_mp_user.try(:id)}",
      "会员消费记录"  => "http://#{Settings.mhostname}/app/vips/consumes?wxmuid=#{current_site.wx_mp_user.try(:id)}",
      "会员积分记录"  => "http://#{Settings.mhostname}/app/vips/points?type=out&wxmuid=#{current_site.wx_mp_user.try(:id)}",
      "微酒店订单管理" => "#{HOTEL_HOST}/wehotel-all/#{current_user.id}/getOrderList"
    }
  end

  #doc start
  #name: truncate_utf
  #desp: 超过固定长度的字符串省略为...
  #param: text 欲处理的字符串、文本
  #param: length 中文汉字的长度
  #param: truncate_string 省略替换文本
  #ex: truncate_utf(self.name.to_s, 6, "..")
  #return: 字符串
  #doc end
  def truncate_utf(text, length = 9, truncate_string = "...")
    textstr = text.to_s
    l=0
    char_array=textstr.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return textstr
  end

  def truncate_u(text, options = {})
    options.reverse_merge!(length: 30, omission: '...')

    l = 0
    char_array = text.to_s.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l + (c < 127 ? 0.5 : 1)
      if l > options[:length]
        return char_array[0...i].pack("U*") + (i ? options[:omission] : "")
      end
    end

    text
  end

  def tr_survey_question(question)
    html = ""
    if question
      html << "<tr><td>#{question.name}</td><td>#{question.limit_select}</td><td>"
      html << "<a class='fgreen' href='javascript:;' data-toggle='modals' data-target='addQuestion' data-height='600' data-title='编辑题目' data-iframe='#{edit_survey_question_path(question, activity_id: params[:activity_id])}'>编辑</a> "
      html << "<a href='#{survey_question_path(question)}' class='fgreen' data-confirm='是否确定要删除这道题目？' data-method='delete' rel='nofollow'>删除</a>"
      html << "</td></tr>"
    end
    return html.html_safe
  end

  def coupon_info(value_by, value)
    if value_by && value_by > 0
      "满#{value_by}减#{value}"
    else
      "#{value}元无限制券"
    end
  end

  #excel导出分页弹窗
  def data_text(total_count, num, exporting_count = EXPORTING_COUNT)
    text = "<div class='col-xs-12'>"
    if [*1..num].each do |i|
      start_count = (i-1)*exporting_count+1
      end_count = i == num ? total_count : i*exporting_count
      text << "<div class='col-xs-4'>
              <label class='margin-b-10 margin-right-20'>
              <input type='radio' name='page_exl' class='ace' value='#{i}' #{'checked' if i == 1 }>"
      if total_count <= exporting_count || total_count == start_count
        text << "<span class='lbl'>第#{total_count}条</span></label></div>"
      else
        text << "<span class='lbl'>#{start_count}-#{end_count}条</span></label></div>"
      end
    end.blank?
      text << "<div class='col-xs-12 text-center'>暂无数据</div>"
    end
    text << "</div>"
    return text
  end

  def website_image_tag(source, options={})
    if /^(http|https):\/\/[a-zA-Z0-9].+$/ =~ source.to_s
      options.merge!({data: {src: source.to_s}})
      source = "#{source}?imageView/2/w/110/h/70"
    end
    image_tag(source, options)
  end

end
