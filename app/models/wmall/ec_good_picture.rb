class Wmall::EcGoodPicture < ActiveRecord::Base
  self.table_name = "wmall_ec_goods_picture"

  def qiniu_pic_url
    qiniu_image_url(pic_key, bucket: BUCKET_WMALL)
  end

end