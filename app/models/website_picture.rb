class WebsitePicture < ActiveRecord::Base
  validates :url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }, allow_blank: true
  validates :title, presence: true, if: :can_validate?

  #这个模型要加上menuable
  attr_accessor :single_material_id, :multiple_material_id, :activity_id, :life_assistant_id, :game_assistant_id, :audio_id, :business_shop_id,
                :docking_type, :docking_function, :good_id, :goods_category_id, :is_delete_cover_pic, :is_delete_pic, :old_parent_id

  enum_attr :menu_type, :in => [
    ['text',1,'文本'],
    ['link', 6, '链接'],
    ['audio_material',5,'语音'],
    ['phone', 7, '电话'],
    ['nav', 11, '导航'],
    ['single_graphic',3,'单图文'],
    ['multiple_graphic',4,'多图文'],
    ['website', 12, '微官网'],
    ['vip', 13, '微会员卡'],
    ['market', 14, '微活动'],
    ['business', 15, '微互动'],
    ['industry', 16, '行业解决方案'],
    ['contact_by_qq', 18, '商家QQ'],
    ['docking', 17, '业务对接'],
    ['activity',2,'活动'],
    ['article', 8, '文章'],
    ['games', 9, '休闲小游戏'],
    ['life_assistant', 10, '生活小助手'],
    ['business_shop', 19, '商铺'],
    ['mobile_qq', 20, 'QQ咨询'],
  ]

  #业务对接模块
  enum_attr :docking_type, :in => [
    ['ec', 1, '微电商'],
  ]

  #具体业务对接功能
  enum_attr :docking_function, :in => [
    ['home', 1, '首页'],
    #['vip_center', 2, '会员中心'],
    #['cart', 3, '购物车'],
    ['goods_category', 4, '商品分类'],
    #['good', 5, '具体商品'],
  ]

  belongs_to :website
  belongs_to :menuable, polymorphic: true

  scope :sorted, -> { order('sort ASC') }

  before_save :cleanup

  def summary
    title
  end

  def name
    title
  end

  def parent?
    false
  end

  alias cover_pic? parent?
  alias has_children? parent?

  def children
    WebsitePicture.none
  end

  def sub_menus
    ret = Array.new
    if self.games? && !self.has_children?
      games = self.website.site.assistants.games.enabled
      games.each do |game|
        ret << game
      end
    else

    end
    return ret
  end

  def pic_url
    qiniu_image_url(pic_key)
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
    end
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

  def get_docking_type
    menuable_type == 'HotelOrder' ? 2 : 1
  end

  def cleanup
    if menu_type.blank?
      self.location_x = nil
      self.location_y = nil
      self.address = nil
      self.menuable_id = nil
      self.menuable_type = nil
      self.url = nil
      self.tel = nil
    elsif link? or phone?
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
      set_docking
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
      end
    end
  end

end
