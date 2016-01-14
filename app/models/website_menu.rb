class WebsiteMenu < ActiveRecord::Base

  NEED_WX_USER_MENUS = ["微会员卡", "营销互动", "行业解决方案"]
  LIMIT_COLUMNS = %W(id website_id parent_id children_count sort sort_type name summary summary_type menu_type menuable_id menuable_type icon_key font_icon url tel address location_x location_y pic_key created_at updated_at qq)

  validates :name, presence: true, length: { maximum: 64, message: '不能超过64个字' }
  validates :tel, presence: true, if: :phone?
  #validates :url, presence: true, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, if: :link?
  validates :url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true
  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true}

  attr_accessor :single_material_id, :multiple_material_id, :activity_id, :life_assistant_id, :game_assistant_id, :audio_id, :title, :business_shop_id,
                :docking_type, :docking_function, :good_id, :goods_category_id, :is_delete_cover_pic, :is_delete_pic, :old_parent_id, :album_id, :panoramagram_id

  belongs_to :website
  belongs_to :material
  belongs_to :menuable, polymorphic: true
  belongs_to :parent, class_name: 'WebsiteMenu', counter_cache: :children_count#, foreign_key: :parent_id
  has_many :children, class_name: 'WebsiteMenu', foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent#, order: ["updated_at desc"]
  has_many :website_articles, dependent: :destroy
  has_one :website_menu_content, dependent: :destroy

  accepts_nested_attributes_for :website_menu_content

  scope :root, -> { where(parent_id: 0) }
  scope :sorted, -> { order('sort ASC') }
  scope :limit_columns, ->(*columns_hash){ columns = LIMIT_COLUMNS; columns_hash.each{|k| columns = columns.send(k[:operator], k[:columns])}; select(columns.uniq.join(', ')) }

  enum_attr :menu_type, :in => [
    ['text',1,'纯文本'],
    ['link', 6, '跳转到链接'],
    ['single_graphic',3,'单图文素材'],
    ['multiple_graphic',4,'多图文素材'],
    ['website', 12, '微官网'],
    ['vip', 13, '微会员卡'],
    ['market', 14, '微活动'],
    ['business', 15, '微互动'],
    ['industry', 16, '行业解决方案'],
    ['docking', 17, '业务对接'],
    ['activity',2,'活动'],
    ['audio_material',5,'语音'],
    ['phone', 7, '电话'],
    ['mobile_qq', 20, 'QQ咨询'],
    ['nav', 11, '导航'],
    ['article', 8, '文章'],
    ['games', 9, '休闲小游戏'],
    ['life_assistant', 10, '生活小助手'],
    ['contact_by_qq', 18, '商家QQ'],
    ['business_shop', 19, '商铺'],
    ['albums', 21, '相册'],
    ['as_article', 22, '文章中心'],
    ['as_product', 23, '展示中心'],
    ['panoramagram', 24, '360全景']
  ]

  enum_attr :sort_style, :in => [
      ['square', 1, "条状"],
      ['circle', 2, "圆状"]
  ]

  enum_attr :sort_type, :in => [
      ['asc', 1, "时间顺序"],
      ['desc', 2, "时间倒序"]
  ]

  #业务对接模块
  enum_attr :docking_type, :in => [
      ['ec', 1, '微电商'],
      ['hotel', 2, '微酒店'],
  ]

  #具体业务对接功能
  enum_attr :docking_function, :in => [
      ['home', 1, '首页'],
      #['vip_center', 2, '会员中心'],
      #['cart', 3, '购物车'],
      ['goods_category', 4, '商品分类'],
      #['good', 5, '具体商品'],
      ['hotel_orders', 6, '订单管理'],
  ]


  enum_attr :subtitle_type, :in => [
      ['no_show', 0, '不显示副标题'],
      ['show_created_at', 1, '副标题显示为创建时间'],
      ['show_content', 2, '副标题显示为内容'],
  ]

  enum_attr :summary_type, :in => [
      ['updated_at', 0, '更新时间'],
      ['created_at', 1, '创建时间'],
      ['no_show_summary', 2, '不显示'],
      ['show_summary', 3, '显示说明'],
  ]

  after_create :update_parent_children_count
  after_destroy :update_parent_children_count
  before_save :cleanup, :icon_dispose, :add_default_attrs
  after_save :update_for_website_menu
  # after_create :generate_preview_pic
  #before_destroy :is_allow_destroy
  #before_create :add_default_attrs

  delegate :content, to: :website_menu_content, allow_nil: true

  def content=(text)
    wmc = if new_record?
      build_website_menu_content(content: text)
    else
      website_menu_content || create_website_menu_content(content: text)
    end
    wmc.content = text
  end

  def need_wx_user?
    WebsiteMenu::NEED_WX_USER_MENUS.include?(self.menu_type_name)
  end

  def title
    name
  end

  def is_children_pic?
    flag = true
    sub_menus.each do |child|
      if child.is_a?(Assistant)
        (flag = false; break) unless child.pic_key.present?
      else
        (flag = false; break) unless child.pic_key.present? || child.font_icon.present?
      end
    end

    if self.multiple_graphic?
      main_material = self.menuable
      if main_material.present?
        flag = false unless main_material.pic_key.present?
        main_material.children.each do |child|
          (flag = false; break) unless child.pic_key.present?
        end
      end
    end
    flag
  end

  def sub_menus
    return children.order(:sort) if has_children?
    games? ? game_assistants : []
  end

  def has_sub_menus?
    return @has_sub_menus if defined?(@has_sub_menus)
    has_children? || has_games?
  end

  def has_games?
    games? && game_assistants.count > 0
  end

  def game_assistants
    @game_assistants ||= website.site.assistants.games.enabled
  end

  def has_children?
    children.count > 0
  end

  def parent?
    parent_id == 0
  end

  def micro_site?
    website.micro_site?
  end

  def com_menu_layer arr
    children.order(:sort).each do |sub_menu|
      next if sub_menu.id == id
      arr << [sub_menu.com_str([sub_menu.name], sub_menu.website.try(:name)), sub_menu.id]
      sub_menu.com_menu_layer arr if sub_menu.has_children?
    end
  end


  def allow_menu_layer sum = 1, is_counter = false
    if parent
      parent.allow_menu_layer sum + 1, is_counter
    else
      is_counter ? sum : sum <= 2
    end
  end

  def com_str str = [], first_name = nil
    if parent
      str.unshift parent.name
      parent.com_str str, first_name
    else
      str.unshift first_name if first_name
      str.join(" > ")
    end
  end

  def com_menu_layer1 arr
    children.each do |sub_menu|
      if sub_menu.allow_menu_layer(1, true) < 3
        arr << [sub_menu.com_str([sub_menu.name], sub_menu.website.name), sub_menu.id]
        sub_menu.com_menu_layer1 arr  if sub_menu.has_children?
      end
    end
  end

  def cleanup
    if link? or phone?
      self.location_x = nil
      self.location_y = nil
      self.address = nil
      self.menuable_id = nil
      self.menuable_type = nil
      self.url = nil if tel?
      self.tel = nil if link?
    elsif nav?
      self.url = nil
      self.tel = nil
      self.menuable_id = nil
      self.menuable_type = nil
    elsif website? or vip? or market? or business? or industry? or business_shop?
      self.location_x = nil
      self.location_y = nil
      self.address = nil
      self.url = nil
      self.tel = nil
      self.menuable_id = self.activity_id
      self.menuable_type = 'Activity'
    elsif docking?
      self.set_docking
    elsif as_article? || as_product?
      self.location_x = nil
      self.location_y = nil
      self.address = nil
      self.menuable_id = nil
      self.menuable_type = nil
      self.url = nil
      self.tel = nil
      self.content = nil
    else
      self.location_x = nil
      self.location_y = nil
      self.address = nil
      self.url = nil
      self.tel = nil
      if self.activity?
        self.menuable_id = self.activity_id
        self.menuable_type = 'Activity'
      elsif self.single_graphic?
        self.menuable_type = 'Material'
        self.menuable_id = self.single_material_id
      elsif self.multiple_graphic?
        self.menuable_type = 'Material'
        self.menuable_id = self.multiple_material_id
      elsif self.life_assistant?
        self.menuable_type = "Assistant"
        self.menuable_id =  self.life_assistant_id
        #assistant = Assistant.find(self.life_assistant_id)
        #url = LIVEASSISTANTURL.select{|u| break u[1] if u[0] == assistant.name}
        #self.url = url
      elsif self.games?
        self.menuable_type = "Assistant"
        self.menuable_id = self.game_assistant_id
      elsif self.audio_material?
        self.menuable_type = 'Material'
        self.menuable_id = self.audio_id
      elsif self.text?
        self.menuable_type = 'WebsiteMenu'
        self.menuable_id = self.id unless self.new_record?
      elsif self.albums?
        self.menuable_type = 'Album'
        self.menuable_id = self.album_id
      elsif self.panoramagram?
        self.menuable_type = 'Activity'
        self.menuable_id = self.panoramagram_id
      end
    end
    unless text?
      self.subtitle = nil
      self.subtitle_type = WebsiteMenu::NO_SHOW
    end
    self.subtitle = nil if self.subtitle_type.to_i == WebsiteMenu::NO_SHOW || self.subtitle_type.to_i == WebsiteMenu::SHOW_CREATED_AT
    self.updated_at = Time.now
  end

  def set_docking
    self.location_x = nil
    self.location_y = nil
    self.address = nil
    self.url = nil
    self.tel = nil
    if self.docking_function.to_i == 1
      self.menuable_type = 'Activity'
      self.menuable_id = website.try(:site).try(:wshop).try(:id)
    #elsif vip_center?
    #  self.menuable_type = 'Vip'
    #  self.menuable_id = website.site_id
    #elsif cart?
    #  self.menuable_type = 'EcCart'
    #  self.menuable_id = website.site_id
    elsif self.docking_function.to_i == 4
      self.menuable_type = 'EcSellerCat'
      self.menuable_id = self.goods_category_id
    #elsif good?
    #  self.menuable_type = 'EcItem'
    #  self.menuable_id = self.good_id
    elsif self.docking_function.to_i == 6
      self.menuable_type = 'HotelOrder'
      self.url = docking_hotel_order_url
    end
  end

  def get_docking_function
    if menuable_type == 'Activity'
      1
    elsif menuable_type == 'Vip'
      2
    elsif menuable_type == 'EcCart'
      3
    elsif menuable_type == 'EcSellerCat'
      4
    elsif menuable_type == 'EcItem'
      5
    elsif menuable_type == 'HotelOrder'
      6
    end
  end

  def get_docking_type
    menuable_type == 'HotelOrder' ? 2 : 1
  end

  def docking_hotel_order_url
    "#{HOTEL_HOST}/wehotel-all/#{website.site_id}/getOrderList?openId="
  end

  def icon_dispose
    if self.pic_key.present?
      self.font_icon = nil
    elsif self.font_icon.present?
      self.pic_key = nil
    end

    if self.is_delete_cover_pic.to_i == 1
      self.cover_pic_key = nil
    end

    if self.is_delete_pic.to_i == 1
      self.pic_key = nil
      self.font_icon = nil
    end

  end

  def update_for_website_menu
    self.update_attribute("menuable_id",self.id) if self.menuable_type == "WebsiteMenu"  && self.menu_type == 1 && self.menuable_id.blank?
  end

  def prev(siblings = [])
    if siblings.present?
      siblings.sort { |m1, m2| m2.sort <=> m1.sort }.find { |m| m.sort < sort }
    else
      self.class.where(parent_id: parent_id, website_id: website_id).where('sort < ?', sort).order('sort DESC').first
    end
  end

  def next(siblings = [])
    if siblings.present?
      siblings.sort { |m1, m2| m1.sort <=> m2.sort }.find { |m| m.sort > sort }
    else
      self.class.where(parent_id: parent_id, website_id: website_id).where('sort > ?', sort).order('sort ASC').first
    end
  end

  def brother_menus
    return [] unless website
    website.website_menus.where(parent_id: self.parent_id)
  end

  def add_default_attrs
    return unless website
    if self.new_record? || self.old_parent_id.to_i != self.parent_id.to_i
      sorts = brother_menus.collect(&:sort)
      if self.parent_id.to_i == 0
        if website.website_menus_sort_type == 1
          self.sort = sorts.max.to_i + 1
        else
          self.sort = sorts.min.to_i - 1
        end
      else
        if self.parent.sort_type == 1
          self.sort = sorts.max.to_i + 1
        else
          self.sort = sorts.min.to_i - 1
        end
      end
    end
    self.summary = nil if [0, 1,2].include?(self.summary_type.to_i)
  end

  def summary
    case read_attribute('summary_type').to_i
      when 0
        updated_at
      when 1
        created_at
      when 2
        nil
      when 3
        read_attribute('summary')
    end
  end

  def stick
    sorts = brother_menus.collect(&:sort)
    update_column('sort', sorts.min.to_i - 1) unless self.sort == sorts.min.to_i
  end

  def asc
    children.order("website_menus.created_at asc").each_with_index{|m,i| m.sort = i}.each{|m| m.update_column('sort', m.sort) if m.sort_changed?}
    update_attributes!(sort_type: WebsiteMenu::ASC) unless self.asc?
  end

  def desc
    children.order("website_menus.created_at desc").each_with_index{|m,i| m.sort = i}.each{|m| m.update_column('sort', m.sort) if m.sort_changed?}
    update_attributes!(sort_type: WebsiteMenu::DESC) unless self.desc?
  end

  def pic_or_icon(options = {})
    result = []
    # 如果是图片则隐藏标题
    options[:hide_title_if_pic] ||= false
    # 图片是否包含i标签外套
    options[:pic_wrap_tag_i] ||= :yes
    options[:pic_type] ||= "custom"
    options[:has_title] ||= false
    options[:title_type] ||= "small"
    options[:not_show_li_if_blank] ||= false
    options[:show_picture_material] ||= :yes

    if self.font_icon.blank? && options[:not_show_li_if_blank]
      result << ""
    elsif options[:show_picture_material].eql?(:yes)
      result << "<i class=\"#{self.font_icon}\"></i>"
    else
      result << ""
    end

    if options[:has_title]
      if options[:title_type] == "small"
        result << "<small>#{self.title}</small>"
      end
    end
    result.join.html_safe
  end

  def is_allow_destroy
    errors.add(:base, '站点下面有子站点，不能直接删除，请先删除这个站点下面的子站点') if has_children?
    errors.full_messages.blank?
  end

  def mobile_websitev02_style(website_template)
  end

  def multilevel_menu_down index, params, menu_categories_selects
    if has_children?
      categories = children.order(:sort)
      menu_categories_selects.push([index, categories])
      if params["menu_category_id#{index}".to_sym].present?
        categories.where(id: params["menu_category_id#{index}".to_sym].to_i).first.try(:multilevel_menu_down, index + 1, params, menu_categories_selects)
      else
        categories.first.try(:multilevel_menu_down, index + 1, params, menu_categories_selects)
      end
    end
  end

  def multilevel_menu params
    return [[1, []]] unless website

    num, menu_categories_selects = allow_menu_layer(1, true), []

    params["menu_category_id#{num}".to_sym] = id
    menu_categories, index = [], 0
    if parent_id == 0
      menu_categories = website.website_menus.root.order(:sort)
      menu_categories_selects.unshift([num, menu_categories.select{|m| m.id != id}])
    else

      menu_categories = parent.children.order(:sort)
      menu_categories_selects.unshift([num, menu_categories.select{|m| m.id != id}])
      parent.try(:multilevel_menu_up, num - 1, params, menu_categories_selects)

      #index = menu_categories.to_a.index(self)
      #if index.to_i == 0
      #  menu_categories[index.to_i + 1].try(:multilevel_menu_down, num + 1, params, menu_categories_selects)
      #else
      #  menu_categories[index.to_i - 1].try(:multilevel_menu_down, num + 1, params, menu_categories_selects)
      #end

    end
    menu_categories_selects
  end

  def multilevel_menu_up index, params, menu_categories_selects
    return unless website
    return unless parent_id
    params["menu_category_id#{index}".to_sym] = id
    if parent_id == 0
      menu_categories_selects.unshift([index, website.website_menus.root.order(:sort)])
    else
      menu_categories_selects.unshift([index, parent.children.order(:sort)])
      parent.try(:multilevel_menu_up, index - 1, params, menu_categories_selects)
    end
  end

  def pic_url
    qiniu_image_url(pic_key)
  end

  def cover_pic_url
    qiniu_image_url(cover_pic_key)
  end

  def default_preview_pic_url
    "/assets/bqq/website_preview_pic.jpg"
  end

  def display_preview_pic_url
    [ WEBSITE_DOMAIN, (preview_pic.present? ? "/uploads/preview_pic/website_menu/#{website_id}/#{preview_pic}" : default_preview_pic_url) ].join
  end

  def generate_preview_pic
    WebsitePreviewPicWorker.perform_async(website_menu_id: parent.id) if parent
  end

  def update_parent_children_count
    WebsiteMenu.where(id: parent_id).update_all(children_count: parent.children.count) if parent
  end

end
