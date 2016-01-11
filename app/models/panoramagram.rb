class Panoramagram < ActiveRecord::Base
	validates :name, presence: true, length: { maximum: 64 }
	validates :pic_key, presence: true

  has_many :items, dependent: :destroy
  has_one :activity, as: :activityable, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def pic_url
  	qiniu_image_url(pic_key)
  end
end
