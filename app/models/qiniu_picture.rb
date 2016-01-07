class QiniuPicture < ActiveRecord::Base
  belongs_to :target, polymorphic: true

  validates_presence_of :sn, :target_id, :target_type
  before_create :shop_branch_picture_count

  def thumb_pic_url
    pic_url && "#{pic_url}?imageView2/1/w/180/h/100"
  end

  def pic_url
    Qiniu.qiniu_image_url(self.sn)
  end

  def shop_branch_picture_count
  	if target_type == "ShopBranch"
  		return false if QiniuPicture.where(target_id: target_id, target_type: "ShopBranch").count >= 10
  	end
  end

end
