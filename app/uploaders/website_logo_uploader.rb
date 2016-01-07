require "digest/md5"
require 'carrierwave/processing/mini_magick'

class WebsiteLogoUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  version :small do
    process :resize_to_fill => [60, 60]
  end

  version :big do
    process :resize_to_fill => [90, 90]
  end

  def filename
    if super.present?
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      if file.extension.present?
        "#{@name}.#{file.extension.downcase}"
      else
        "#{@name}.jpg"
      end
    end
  end

end
