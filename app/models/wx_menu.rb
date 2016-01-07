# == Schema Information
#
# Table name: wx_menus
#
#  id            :integer          not null, primary key
#  supplier_id   :integer
#  wx_mp_user_id :integer          not null
#  parent_id     :integer          default(0), not null
#  sort          :integer          default(0), not null
#  name          :string(255)
#  key           :string(255)
#  url           :string(255)
#  event_type    :string(255)      default("click"), not null
#  menu_type     :string(255)      default("1"), not null
#  menuable_id   :integer
#  menuable_type :string(255)
#  content       :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class WxMenu < ActiveRecord::Base
  # attr_accessible :event_type, :key, :name, :parent_id
  attr_accessor :material_id, :activity_id, :audio_id, :video_id, :album_id, :panoramagram_id

  validates :name, :key, :event_type, presence: true
  validates :content, presence: true, if: :text?
  validates :material_id, presence: true, if: :material_and_child?
  validates :activity_id, presence: true, if: :activity_and_child?
  validates :album_id, presence: true, if: :album_and_child?
  validates :panoramagram_id, presence: true, if: :panoramagram_and_child?
  validates :url, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: "地址格式不正确，请重新输入，例如：http://www.baidu.com" }, if: :link?

  belongs_to :parent, class_name: 'WxMenu', foreign_key: :parent_id
  has_many :children, class_name: 'WxMenu', foreign_key: :parent_id, dependent: :destroy#, order: :sort
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :menuable, polymorphic: true

  scope :root, -> { where(parent_id: 0) }

  accepts_nested_attributes_for :children, reject_if: proc { |attributes| attributes['name'].blank? }

  acts_as_enum :menu_type, :in => [
    ['text',1,'纯文本'],
    ['link',6,'跳转到链接'],
    ['material',2,'图文素材'],
    ['activity',3,'活动应用'],
    ['audio',4,'语音'],
    # ['phone', 7, '电话'],
    # ['video_material',8,'视频']
    ['games',9,'休闲小游戏'],
    #10，11,12 已被锦江，去哪儿吃,永安保险使用，请从13开始
    ['albums',13,'相册'],
    ['panoramagram',14,'360全景'],
    ['dkf', 15, '多客服'],
  ]

  acts_as_enum :event_type, :in => [
    ['click', '点击'],
    ['view', '链接'],
  ]

  before_save :cleanup

  def material_and_child?
    material? && child?
  end

  def activity_and_child?
    activity? && child?
  end

  def album_and_child?
    albums? && child?
  end

  def panoramagram_and_child?
    panoramagram? && child?
  end

  def has_children?
    children.count > 0
  end

  def parent?
    parent_id == 0
  end

  def child?
    parent_id > 0
  end

  def cleanup
    if self.menu_type.to_i == 6
      self.menuable_id = nil
      self.menuable_type = nil
      self.event_type = "view"
    else
      self.event_type = "click"
      if [1,15].include?(self.menu_type.to_i)
        self.menuable_id = nil
        self.menuable_type = nil
      else
        self.content = nil
        if self.menu_type.to_i == 3
          self.menuable_id = self.activity_id
          self.menuable_type = 'Activity'
        elsif self.menu_type.to_i == 2
          self.menuable_id = self.material_id
          self.menuable_type = 'Material'
        elsif self.menu_type.to_i == 4
          self.menuable_id = self.audio_id
          self.menuable_type = 'Material'
        elsif self.menu_type.to_i == 9
          # self.menuable_id = self.game_assistant_id 
          self.menuable_type = "Assistant"
        elsif self.menu_type.to_i == 13
          self.menuable_id = self.album_id 
          self.menuable_type = "Album"
        elsif self.menu_type.to_i == 14
          self.menuable_id = self.panoramagram_id 
          self.menuable_type = "Activity"
        end
      end
    end
  end

  def with_face_image_text
    return '' unless text?
    return content unless content.to_s.include?('/')

    text = content
    TQQ_FACES.values.each_with_index do |v, i|
      face = "/#{v}"
      text.gsub!(/#{face}/, "<img src='/assets/faces/#{TQQ_FACES.keys[i]}.gif' alt='#{v}' title='#{v}' />") if text.include?(face)
    end
    text
  end

  def add_sort
    self.sort += 1
    self.sort = 1 if self.sort < 1
    self.update_column :sort, self.sort
  end

  def minus_sort
    self.sort -= 1
    self.sort = 1 if self.sort < 1
    self.update_column :sort, self.sort
  end

  def self.new_sort(menus)
    menus.each_with_index do |menu,index|
      menu.sort = index + 1
      menu.update_column :sort, menu.sort
    end
  end

  def wx_api_json
    if has_children?
      {name: name, sub_button: children.order(:sort).map(&:child_wx_api_json)}
    else
      child_wx_api_json
    end
  end

  def child_wx_api_json
    if click?
      {type: event_type, name: name, key: key}
    elsif view?
      {type: event_type, name: name, url: url}
    end
  end

end

