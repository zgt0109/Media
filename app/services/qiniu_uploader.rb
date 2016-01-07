class QiniuUploader
  def self.upload(file, bucket: BUCKET_PICTURES)
    raise 'file can not be blank' if file.blank?
    file_path = case
    when file.respond_to?(:path) then file.path
    when file =~ /\Ahttp/
      origin_file = open(file)
      if origin_file.class.name.eql?("StringIO")
        temp_file = Tempfile.new(['temp','.jpg'])
        temp_file.binmode
        temp_file.write origin_file.read
        temp_file.close
        temp_file.path
      else
        origin_file.path
      end
    else file
    end
    put_policy = Qiniu::Auth::PutPolicy.new(bucket)
    Qiniu::Storage.upload_with_put_policy(put_policy, file_path)
  end
end
