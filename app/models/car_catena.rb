class CarCatena < ActiveRecord::Base
  belongs_to :car_brand
  has_many :car_pictures, dependent: :destroy
  has_many :car_types, dependent: :destroy

  validates :name, :presence => true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  def pic_url
    qiniu_image_url(pic_key)
  end

  def display_name
    name[0..15] rescue ""
  end

	def delete!
		update_attributes(status: DELETED) if normal?
	end

end
