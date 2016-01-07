module QiNiu
  def qiniu_image_url(key, bucket: BUCKET_PICTURES)
    key.present? ? "http://#{bucket}.#{QINIU_DOMAIN}/#{key}" : nil
  end
end
