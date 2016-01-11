class ShareSetting < ActiveRecord::Base
  belongs_to :shareable, polymorphic: true

  def pic_url
    qiniu_image_url(pic_key, bucket: BUCKET_PICTURES)
  end

end
