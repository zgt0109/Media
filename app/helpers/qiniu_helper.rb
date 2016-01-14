module QiniuHelper
  def qiniu_img_url(pic_key, default_pic: "bg_fm.jpg", type: nil)
    if pic_key.present?
      type ? "#{qiniu_image_url(pic_key)}?imagePreview/#{type}" : qiniu_image_url(pic_key)
    else
      default_pic
    end
  end

  def qiniu_auto_orient_url(pic_key)  
    "#{qiniu_image_url(pic_key)}?imageMogr2/auto-orient"
  end
end
