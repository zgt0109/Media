require "celluloid"
class ImgUploadQiniu
  include Celluloid
  #二进制图片上传七牛
  def self.upload_qiniu(img)
    Tempfile.open('qrcode_img', encoding: 'ascii-8bit') do |tempfile|
      tempfile.write(img)
      put_policy = Qiniu::Auth::PutPolicy.new(BUCKET_PICTURES)
      code, result, response_headers = Qiniu::Storage.upload_with_put_policy(put_policy,tempfile.path)
      result["key"]
    end
  end

  def up_website_qrcode(webs)
    webs.each do |web|
      web.upload_qrcode_to_qiniu
      puts "*****website_id=#{web.id}*******qrcode_qiniu_key=#{web.qrcode_qiniu_key}********"
    end
  end

  def self.prize_pic_to_qiniu(img_path)
    put_policy = Qiniu::Auth::PutPolicy.new(BUCKET_PICTURES)
    code, result, response_headers = Qiniu::Storage.upload_with_put_policy(put_policy,img_path)
    result["key"]
  end
end