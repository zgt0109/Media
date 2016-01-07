class Wmall::Picture < ActiveRecord::Base
  belongs_to :pictureable ,class_name: "Wmall::Coupon", :polymorphic => true

  # def pictureable
  #   class_type = "Wmall::#{pictureable_type}"
  #   Kernel.const_get(class_type).where(id: pictureable_id).first
  # end
  def qiniu_pic_url
    qiniu_image_url(pic_key, bucket: BUCKET_WMALL)
  end
end