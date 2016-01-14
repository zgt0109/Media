class CarSeller < ActiveRecord::Base

	validates :name, :phone, :position, :skilled_language, presence: true

  enum_attr :status, :in => [['normal', 1, '正常'],['deleted', -1, '已删除']]

  enum_attr :seller_type, :in => [
    ['sales_rep', 1, '销售代表'],
    ['sales_consultant', 2, '销售顾问'],
  ]

	belongs_to :car_shop

	def delete!
		update_attributes(status: DELETED) if normal?
	end

  def pic_url
    qiniu_image_url(pic_key)
  end

end
