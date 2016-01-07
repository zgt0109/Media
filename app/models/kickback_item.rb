class KickbackItem < ActiveRecord::Base
  belongs_to :wx_user
  belongs_to :kickback
  # attr_accessible :title, :body
  validate :id_card_no_uniq
  before_create :add_default_properties!

  enum_attr :status, :in => [
    ['unpay', 1, '未锁定'],
    ['payed', 2, '已锁定']
  ]

  def finished?
    !!self.wx_user
  end

  scope :unfinished,  -> { where("wx_user_id is null") } #没被领取
  scope :finished, -> { where("wx_user_id is not null") } #被领取了

  def id_card_no_uniq
    if self.id_card_no.blank?
      return true;
    end
    if KickbackItem.exists?(id_card_no: self.id_card_no)
      errors.add(:id_card_no, "身份证号码已被使用")
    end
  end

  def add_default_properties!
    if self.word.blank?
      self.word = "多谢你助我做雷锋"
    end
  end
end
