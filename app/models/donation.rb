class Donation < ActiveRecord::Base
  enum_attr :status, :in => [
    ['normal', 1, '进行中'],
    ['soldout', -1, '已停止'],
  ]

  validates :name, :target_money, :summary, :detail, :group_name, presence: true
  validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  belongs_to :site
  belongs_to :activity
  has_many :donation_orders

  def pic_url
    pic_key.present? ? qiniu_image_url(pic_key) : "http://www.winwemedia.com/assets/bg_fm.jpg"
  end
end
