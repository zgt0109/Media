class SupplierPrintUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  def store_dir
    "uploads/supplier_prints/#{model.id}"
  end
  
  version :thumb do
    process :resize_to_fill => [40, 40]
  end

  version :large do
    process :resize_to_fit => [344, 344]
  end

  def filename
    if super.present?
      # current_path 是 Carrierwave 上传过程临时创建的一个文件，有时间标记，所以它将是唯一的
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      # @name ||= model.id
      if file.extension.present?
        "#{@name}.#{file.extension.downcase}"
      else
        "#{@name}.jpg"
      end
    end
  end
end