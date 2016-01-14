class HouseExpert < ActiveRecord::Base

  validates :name, :intro, presence: true, length: { maximum: 50 }

  enum_attr :status, :in => [['normal', 1, '正常'],['deleted', -1, '已删除']]

  belongs_to :house
  has_many :house_expert_comments, dependent: :destroy

  def pic_url
    qiniu_image_url pic_key
  end

  def delete!
    update_attributes(status: DELETED) if normal?
  end
end
