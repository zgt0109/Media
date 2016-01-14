class CarBrand < ActiveRecord::Base
  validates :name, presence: true

  has_many :car_types
  has_many :car_catenas
  belongs_to :car_shop

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def delete!
    update_attributes(status: DELETED) if normal?
  end

  def logo_url(type = :large)
    qiniu_image_url(logo_key)
  end

end
