class HomePicUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  def store_dir
    "uploads/home_pictures/#{model.id}"
  end
  
  version :thumb do
    process :resize_to_fill => [220, 140]
  end

end