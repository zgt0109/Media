class Panoramagram::Item < ActiveRecord::Base
  belongs_to :panoramagram

  before_create :set_supplier_id

  def pic_url
    qiniu_image_url(qiniu_pic_key)
  end

  def set_supplier_id
  	self.supplier_id = self.panoramagram.supplier_id
  end
end
