module QiniuHelper
  def qiniu_img_url(pic, default_pic: "bg_fm.jpg", type: nil)
    if pic.present?
      if type
        url = "#{qiniu_image_url(pic)}?imagePreview/#{type}"
      else
        url = qiniu_image_url(pic)
      end
    else
      url = default_pic
    end
  end

  def qiniu_auto_orient_url(pic)  
    "#{qiniu_image_url(pic)}?imageMogr2/auto-orient"
  end
end
