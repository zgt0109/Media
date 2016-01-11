class Panoramagram::Item < ActiveRecord::Base
  belongs_to :panoramagram

  before_create :set_site_id

  def pic_url
    qiniu_image_url(pic_key)
  end

  def set_site_id
  	self.site_id = self.panoramagram.site_id
  end
end
