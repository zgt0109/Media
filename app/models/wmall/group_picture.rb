class Wmall::GroupPicture < ActiveRecord::Base
  self.table_name = "wmall_group_pictures"

  def qiniu_pic_url
    qiniu_image_url(pic_key, bucket: BUCKET_WMALL)
  end

end