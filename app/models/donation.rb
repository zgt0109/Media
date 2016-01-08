class Donation < ActiveRecord::Base
  # attr_accessible :default_money, :detail, :feedback, :group_name, :name, :order, :pic, :qualification, :status, :summary, :target_money
  enum_attr :status, :in => [
    ['normal', 1, '进行中'],
    ['soldout', -1, '已停止'],
  ]
  belongs_to :supplier
  validates :name, presence: true
  validates :target_money, presence: true
  validates :summary, presence: true
  validates :pic, presence: true, on: :create
  validates :detail, presence: true
  validates :group_name, presence: true
  validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  belongs_to :activity
  has_many :donation_orders

  def pic_url
    pic_key.present? ? qiniu_image_url(pic_key) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end
end
