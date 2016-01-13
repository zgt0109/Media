# == Schema Information
#
# Table name: album_photos
#
#  id          :integer          not null, primary key
#  album_id    :integer
#  name        :string(255)
#  pic         :string(255)
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AlbumPhoto < ActiveRecord::Base

  has_many   :comments, as: :commentable, dependent: :destroy
  belongs_to :album, counter_cache: :photos_count

  before_save :save_pic_name

  def save_pic_name
  	self.name ||= filename
  end

  def filename
    pic.file && pic.file.filename || pic_key
  end
  
  def img_url
    if qiniu_pic_url && album.site.album_activity.show_watermark? && album.site.album_activity.album_watermark_img.present?
      return "#{qiniu_pic_url}?imageView2/2/w/640/h/1136|watermark/1/image/#{album.site.album_activity.album_watermark_encode}/dissolve/50"
    end
    qiniu_pic_url
  end

  def thumb_pic_url
    @thumb_pic_url ||= thumb_qiniu_pic_url
  end

  def thumb_qiniu_pic_url
    # 七牛缩略图说明 http://developer.qiniu.com/docs/v6/api/reference/fop/image/imageview2.html
    qiniu_pic_url && "#{qiniu_pic_url}?imageView2/1/w/180/h/100"
  end

  def qiniu_pic_url
    qiniu_image_url(pic_key)
  end

end
