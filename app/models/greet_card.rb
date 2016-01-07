class GreetCard < ActiveRecord::Base
  belongs_to :material
  belongs_to :greet
  # attr_accessible :card_pic, :card_type, :content, :title, :title_pic
  mount_uploader :title_pic, GreetCardTitleUploader
  mount_uploader :card_pic, GreetCardPicUploader
  img_is_exist({title_pic: :qiniu_title_pic_key, card_pic: :qiniu_card_pic_key})

  validates :title, :content, presence: true
  # validates :title_pic, presence: true, on: :create
  # validates :card_pic, presence: true, on: :create
  
  before_save :clean_up

  default_scope where(["greet_cards.status != ? ", -1 ])

  scope :visitable, -> { where("greet_cards.status = ?", 1) }

  enum_attr :status, :in => [
    ['used', 1, '使用中'],
    ['hidden', 2, '已隐藏'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :card_type, :in => [
    ['voice', 1, '语音' ],
    ['word', 2, '文字']
  ]

  def delete!
    update_attributes(status: DELETED)
  end

  def hidden!
    update_attributes(status: HIDDEN)
  end

  def view!
    update_attributes(status: USED)
  end

  def clean_up
    self.has_audio = true if self.material_id.to_i > 0
    self.material = nil if self.card_type == 1
    self.title_pic = nil if self.recommand_title_pic.present? || self.qiniu_title_pic_key.present?
    self.card_pic = nil if self.recommand_card_pic.present? || self.qiniu_card_pic_key.present?
  end

  def title_pic_url
    if self.qiniu_title_pic_key.present?
      QiNiu.qiniu_image_url self.qiniu_title_pic_key
    elsif self.recommand_title_pic.present?
      self.recommand_title_pic
    else
      self.title_pic.large
    end
  end

  def card_pic_url
    if self.qiniu_card_pic_key.present?
      QiNiu.qiniu_image_url self.qiniu_card_pic_key
    elsif self.recommand_card_pic.present?
      self.recommand_card_pic
    else
      self.card_pic.large
    end
  end

end
