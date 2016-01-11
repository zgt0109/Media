class Website < ActiveRecord::Base

  validates :name, presence: true, length: { maximum: 64, message: '官网名称过长' }
  validates :address, presence: true, if: :can_validate?
  # validates :address, presence: true
  validates_uniqueness_of :domain, :allow_blank => true, :allow_nil => true, :format => { :with => /^[a-zA-Z_\-][\w\-]{2,14}/ }

  enum_attr :template_id, :in => [
    ['template1', 1, '暗黑系'],
    ['template2', 2, '小清新'],
    ['template3', 3, '时光流'],
    ['template4', 4, '商务蓝'],
    ['template5', 5, '全屏左'],
    ['template6', 6, '底部导航栏'],
    ['template7', 7, '全屏中'],
    ['template8', 8, '左双栏'],
    ['template9', 9, '左三栏'],
    ['template10', 10, '方块八'],
    ['template11', 11, 'Win8风格'],
    ['template12', 12, '双栏紫'],
    ['template13', 13, 'Win8导航'],
    ['template14', 14, '七彩版'],
    ['template15', 15, 'Win8楼书'],
    ['template16', 16, '自定义菜单']
  ]

  enum_attr :website_type, :in => [
    ['micro_site', 1, '微官网'],
    ['micro_life', 2, '微生活'],
    ['micro_circle', 3, "微商圈"]
  ]

  enum_attr :status, :in => [
    ['active', 1, "正常"],
    ['froze', -1, "已冻结"],
    ['force_froze', -2, "已强制冻结"],
  ]

  enum_attr :website_menus_sort_type, :in => [
    ['asc', 1, "时间顺序"],
    ['desc', 2, "时间倒序"]
  ]

  belongs_to :site
  belongs_to :activity
  belongs_to :city
  has_one :website_setting, dependent: :destroy
  has_one :life_activity, class_name: 'Activity', as: :activityable
  has_one :circle_activity, class_name: 'Activity', as: :activityable
  has_one :webiste_activity, class_name: 'Activity', as: :activityable
  has_many :website_menus, dependent: :destroy#, order: :sort
  has_many :website_pictures, dependent: :destroy
  has_many :website_popup_menus, class_name: 'WebsitePopupMenu', dependent: :destroy
  has_many :shortcut_menus, class_name: 'WebsitePopupMenu', conditions: { nav_type: WebsitePopupMenu::POPUP_MENU }, dependent: :destroy
  has_many :home_nav_menus, class_name: 'WebsitePopupMenu', conditions: { nav_type: WebsitePopupMenu::HOME_NAV_MENU }, dependent: :destroy
  has_many :inside_nav_menus, class_name: 'WebsitePopupMenu', conditions: { nav_type: WebsitePopupMenu::INSIDE_NAV_MENU }, dependent: :destroy
  has_many :website_articles, dependent: :destroy
  has_many :website_article_categories, dependent: :destroy
  has_many :business_shops, dependent: :destroy
  has_many :categories, class_name: 'WebsiteArticleCategory'

  accepts_nested_attributes_for :life_activity
  accepts_nested_attributes_for :circle_activity
  accepts_nested_attributes_for :website_setting
  accepts_nested_attributes_for :activity

  before_save :update_is_open_life_popup
  after_create :create_default_setting
  after_save :upload_qrcode_to_qiniu

  def update_is_open_life_popup
    self.is_open_life_popup = true if is_open_life_popup.nil?
  end

  def upload_qrcode_to_qiniu
    url = "#{MOBILE_DOMAIN}/#{custom_domain}?id=#{id}&aid=#{activity_id}&anchor=mp.weixin.qq.com"
    rqrcode = nil
    1.upto(12) do |size|
      break rqrcode = RQRCode::QRCode.new(url, :size => size, :level => :h ).to_img.resize(258, 258) rescue next
    end
    img = Magick::Image::read_inline(rqrcode.to_data_url).first.adaptive_blur #二维码作为背景图
    # if self.logo?
    #   mark = Magick::ImageList.new
    #   begin
    #     logo = logo_key.present? ? mark.from_blob(open(qiniu_image_url(logo_key)).read) : mark.read(logo.current_path)
    #     img = img.composite(logo.resize(60, 60), 99, 99, Magick::OverCompositeOp)
    #   rescue

    #   end
    # end
    update_column(:qrcode_qiniu_key, ImgUploadQiniu.upload_qiniu(img.to_blob))
  end

  def pic_url
    qiniu_image_url(qrcode_qiniu_key)
  end

  def clear_menus!
    website_menus.clear
  end

  def open_popup_menu!
    update_attributes!(is_open_popup_menu: true)
  end

  def close_popup_menu!
    update_attributes!(is_open_popup_menu: false)
  end

  def open_life_popup!
    update_attributes!(is_open_life_popup: true)
  end

  def close_life_popup!
    update_attributes!(is_open_life_popup: false)
  end

  def asc
    website_menus.root.order("website_menus.created_at asc").each_with_index{|m,i| m.sort = i}.each{|m| m.update_column('sort', m.sort) if m.sort_changed?}
    update_attributes!(website_menus_sort_type: Website::ASC) unless self.asc?
  end

  def desc
    website_menus.root.order("website_menus.created_at desc").each_with_index{|m,i| m.sort = i}.each{|m| m.update_column('sort', m.sort) if m.sort_changed?}
    update_attributes!(website_menus_sort_type: Website::DESC) unless self.desc?
  end

  def show_layer_menus website_menu
    arr = [[name, 0]]
    website_menus.root.order(:sort).each do |menu|
      next if menu.id == website_menu.id
      arr << [menu.com_str([menu.name], name), menu.id]
      menu.com_menu_layer arr if menu.has_children?
    end
    arr
  end

  def show_layer_menus1 website_menu
    arr = [[name, 0]]
    if website_menu.allow_menu_layer(1, true) == 3
      website_menus.root.each do |menu|
        arr << [menu.com_str([menu.name], name), menu.id]
        menu.com_menu_layer1 arr if menu.has_children?
      end
    elsif website_menu.allow_menu_layer(1, true) == 2
      arr = website_menus.root.map{|menu| [menu.com_str([menu.name], name), menu.id]}
    end
    arr
  end

  def custom_domain
    site_id
  end

  def rqrcode(url = nil)
    #require 'RMagick'
    url = "#{MOBILE_DOMAIN}/#{custom_domain}" if url.blank?
    rqrcode = nil
    1.upto(15) do |size|
      break rqrcode = RQRCode::QRCode.new(url, :size => size, :level => :h ).to_img.resize(258, 258) rescue next
    end

    # 二维码作为背景图
    img = Magick::Image::read_inline(rqrcode.to_data_url).first rescue ""
    # if self.logo?
    #   mark = Magick::ImageList.new
    #   begin
    #     logo = logo_key.present? ? mark.from_blob(open(qiniu_image_url(logo_key)).read) : mark.read(logo.current_path)
    #     img = img.composite(logo.resize(60, 60), 99, 99, Magick::OverCompositeOp)
    #   rescue
    #   end
    # end
    return img
  end

  #def rqrcode url
  #  RQRCode::QRCode.new( url, :size => 4, :level => :h ).to_img.resize(90, 90)
  #end

  def download
    self.rqrcode.to_blob
  end

  def preview
    data_uri = Base64.encode64(self.rqrcode.to_blob).gsub(/\n/, "")
    image_tag = '<img alt="preview" src="data:image/jpeg;base64,%s">' % data_uri
  end

  def copy_website_popup_menus start = WebsitePopupMenu::HOME_NAV_MENU, finish = WebsitePopupMenu::INSIDE_NAV_MENU
    menus = []
    website_popup_menus.where(nav_type: finish).map &:destroy
    website_popup_menus.where(nav_type: start).find_each do |menu|
      attrs = {
          nav_type: finish,
          activity_id: menu.activity? ? menu.menuable_id : nil,
          single_material_id: menu.single_graphic? ? menu.menuable_id : nil,
      }
      website_popup_menu = WebsitePopupMenu.new(menu.attributes.merge!(attrs))
      website_popup_menu.save
      menus << website_popup_menu
    end
    menus
  end

  def nav_menus_class_name
    @nav_menus_class_name ||= {21 => 'fa fa-home', 22 => 'fa fa-refresh', 23 => 'fa fa-reply', 24 => 'fa fa-share', 7 => 'fa fa-phone'}
  end

  def nav_menus_default_datas
    @nav_menus_default_datas ||= {
        2 => [23, 24, 21, 22],
        3 => [23, 24, 21, 22],
        4 => [23, 24, 21, 22, 7],
        5 => [23, 24, 21],
        6 => [23, 24, 21, 22],
        7 => [23, 24, 21, 22],
        9 => [23, 24, 21],
        10 => [23, 21, 24],
        11 => [23, 24, 21],
        12 => [23, 24, 21],
        13 => [23, 24, 21],
        15 => [23, 24, 21, 22],
        16 => [21, 23, 24, 22, 7],
        19 => [23, 24, 21, 22],
        20 => [23, 24, 21, 22],
        22 => [23, 24, 21, 22],
    }
  end

  def website_popup_menus_initialize(nav_type)
    raise "只有导航模版菜单允许初始化" unless [WebsitePopupMenu::HOME_NAV_MENU, WebsitePopupMenu::INSIDE_NAV_MENU].include?(nav_type)
    raise "无法读取到网站配置" unless @website_setting = self.website_setting
    nav_template_id = (nav_type == WebsitePopupMenu::HOME_NAV_MENU) && @website_setting.index_nav_template_id.to_i || @website_setting.nav_template_id.to_i
    raise "该导航模版不支持自定义菜单" unless self.nav_menus_default_datas.keys.include?(nav_template_id)
    self.nav_menus_default_datas[nav_template_id].each do |m|
      attrs = {
          menu_type: m,
          nav_type: nav_type.to_i,
          font_icon: self.nav_menus_class_name[m],
          tel: m == 7 ? shortcut_menus.phone.first.try(:tel) : nil
      }
      website_popup_menus << website_popup_menus.new(attrs)
    end
  end

  def create_default_setting
    return if website_setting.present?
    create_website_setting
  end

  #创建微官网初始化数据
  def create_default_data
    create_default_website_menus
    create_default_website_pictures
    create_default_website_popup_menus
  end

  #获取测试帐号微官网数据
  def get_test_website
    if Rails.env.staging? || Rails.env.production?
      @supplier_id = 11805
    else
      @supplier_id = 10001
    end
    Website.where(supplier_id: @supplier_id, website_type: Website::MICRO_SITE).first
  end

  #创建微官网站点初始化数据
  def create_default_website_menus
    website = get_test_website

    return unless website
    return unless website.website_menus

    website.website_menus.root.order(:sort).each do |menu|
      next unless [1, 6, 7, 9, 11, 18].include? menu.menu_type.to_i
      website_menu = WebsiteMenu.new(menu.attributes)
      full_attrs = {
          website_id: id,
          pic: menu.pic? ? File.open(menu.pic.current_path) : nil,
          cover_pic: menu.cover_pic? ? File.open(menu.cover_pic.current_path) : nil,
      }

      website_menu.update_attributes(full_attrs)
      next unless menu.children

      create_default_website_sub_menus menu, website_menu
    end
  end

  #创建微官网站点初始化数据
  def create_default_website_sub_menus menu, parent
    menu.children.each do |sub_menu|
      next unless [1, 6, 7, 9, 11, 18].include? sub_menu.menu_type.to_i
      website_menu = WebsiteMenu.new(sub_menu.attributes)
      full_attrs = {
          website_id: id,
          parent_id: parent.id,
          pic: menu.pic? ? File.open(menu.pic.current_path) : nil,
          cover_pic: menu.cover_pic? ? File.open(menu.cover_pic.current_path) : nil,
      }

      website_menu.update_attributes(full_attrs)
      next unless menu.children

      create_default_website_sub_menus sub_menu, website_menu
    end
  end

  #创建微官网首页幻灯片初始化数据
  def create_default_website_pictures
    website = get_test_website

    return unless website
    return unless website.website_pictures

    website.website_pictures.each do |picture|
      website_picture = WebsitePicture.new(picture.attributes)
      website_picture.update_attributes({website_id: id, pic: File.open(picture.pic.current_path)})
    end
  end

  #创建微官网快捷菜单初始化数据
  def create_default_website_popup_menus
    website = get_test_website

    return unless website
    return unless website.website_popup_menus

    website.website_popup_menus.each do |menu|
      next unless [6, 7, 11].include? menu.menu_type.to_i
      website_popup_menu = WebsitePopupMenu.new(menu.attributes)
      full_attrs = {
          website_id: id,
          icon: menu.icon? ? File.open(menu.icon.current_path) : nil,
      }
      website_popup_menu.update_attributes(full_attrs)
    end
  end

  def logo_url(type = :big)
    qiniu_image_url(logo_key)
  end

  def default_preview_pic_url
    "/assets/bqq/website_preview_pic.jpg"
  end

  def display_preview_pic_url
    [ WEBSITE_DOMAIN, (preview_pic.present? ? "/uploads/preview_pic/website_menu/#{id}/#{preview_pic}" : default_preview_pic_url) ].join
  end
  
end
