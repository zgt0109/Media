# == Schema Information
#
# Table name: website_popup_menus
#
#  id            :integer          not null, primary key
#  website_id    :integer
#  sort          :integer          default(0), not null
#  menu_type     :integer          default(1), not null
#  menuable_id   :integer
#  menuable_type :string(255)
#  icon          :string(255)
#  tel           :string(255)
#  url           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class WebsitePopupMenu < ActiveRecord::Base
  attr_accessor :single_material_id, :multiple_material_id, :activity_id

  mount_uploader :icon, WebsitePopupMenuUploader
  mount_uploader :pic, WebsitePopupMenuUploader

  img_is_exist({icon: :icon_key, pic: :icon_key})

  scope :root, -> { where(parent_id: 0) }

  enum_attr :menu_type, :in => [
    # ['text', 1, '文本'],
    ['activity', 2, '活动'],
    ['single_graphic', 3, '素材'],
    # ['multiple_graphic', 4, '多图文素材'],
    # ['audio_material', 5, '语音'],
    ['link', 6, '链接'],
    ['phone', 7, '电话'],
    ['nav', 11, '一键导航'],
    ['index', 21, '操作_首页'],
    ['refresh', 22, '操作_刷新'],
    ['prev', 23, '操作_后退'],
    ['next', 24, '操作_前进'],
  ]

  enum_attr :nav_type, :in => [
    ['popup_menu', 0, '弹出菜单'],
    ['home_nav_menu', 1, '首页导航'],
    ['inside_nav_menu', 2, "内页导航"]
  ]

  #validates :icon, presence: true, :if => "font_icon.blank?"
  #validates :font_icon, presence: true, :if => "icon.blank?"
  validates :sort, presence: true
  validates :sort, numericality: { only_integer: true, greater_than_or_equal_to: 0}

  belongs_to :website
  belongs_to :menuable, polymorphic: true
  belongs_to :parent, class_name: 'WebsitePopupMenu', foreign_key: :parent_id
  has_many :children, class_name: 'WebsitePopupMenu', foreign_key: :parent_id

  before_save :cleanup, :icon_dispose
  before_create :add_default_attrs
  #after_destroy :update_brother_nodes

  def operation_title
      @operation_title ||= if self.name.present?
        self.name
      else
        case self.menu_type
        when 21
          "首页"
        when 22
          "刷新"
        when 23
          "后退"
        when 24
          "前进"
        else
          ""
        end
      end
  end

  def operation_class_name
      @operation_class_name ||= case self.menu_type
      when 21
        "dev-index"
      when 22
        "dev-refresh"
      when 23
        "dev-prev"
      when 24
        "dev-next"
      else
        ""
      end
  end

  def title
    name
  end

  def description
    if link?
      url
    elsif phone?
      tel
    elsif activity?
      menuable.try(:name)
    elsif nav?
      address
    elsif single_graphic?
      menuable.try(:title)
    else
      menu_type_name
    end
  end

  def cleanup
    if link? or phone?
      self.location_x = nil
      self.location_y = nil
      self.menuable_id = nil
      self.menuable_type = nil
      self.address = nil
      self.url = nil if tel?
      self.tel = nil if link?
    elsif nav?
      self.url = nil
      self.tel = nil
      self.menuable_id = nil
      self.menuable_type = nil
    else
      self.address = nil
      self.location_x = nil
      self.location_y = nil
      # self.content = nil
      self.url = nil
      self.tel = nil
      if self.activity?
        self.menuable_id = self.activity_id
        self.menuable_type = 'Activity'
      else
        self.menuable_type = 'Material'
        if self.single_graphic?
          self.menuable_id = self.single_material_id
        # elsif self.multiple_graphic?
        #   self.menuable_id = self.multiple_material_id
        # elsif self.audio_material?
        #   self.menuable_id = self.audio_id
        end
      end
    end
  end

  def icon_dispose
    if self.icon_key.present?
      self.remove_icon!
      self.font_icon = nil
    elsif self.font_icon.present?
      self.remove_icon!
      self.icon_key = nil
    elsif
      self.icon_key = nil
      self.font_icon = nil
    end
  end

  def add_default_attrs
    return unless website
    return unless self.sort == 0
    self.sort = website.website_popup_menus.where(nav_type: self.nav_type).order(:sort).try(:last).try(:sort).to_i + 1
  end

  def update_brother_nodes
    return unless website
    menus = website.website_popup_menus.where(nav_type: self.nav_type).all
    menus.each_with_index{|menu, index| menu.sort = index + 1}.each{|menu| menu.update_column('sort', menu.sort) if menu.sort_changed?}
  end

  def icon_url(type = :thumb)
    qiniu_image_url(icon_key) || icon.try(type)
  end

  def parent_name
    parent_id.to_i == 0 ? '主分类' : parent.description
  end

end
