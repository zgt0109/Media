class WxWallPrize < ActiveRecord::Base
	belongs_to :wx_wall
  has_many :wx_wall_prizes_wx_wall_users
  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除'],
  ]

  validates :name, :grade, :num, presence: true
  validates :num, numericality: {greater_than: 0, less_than_or_equal_to: 10000, only_integer: true}, if: :can_validate?

  def pic_url
    pic.present? ? qiniu_image_url(pic) : "/assets/bg_fm.jpg"
  end

end
