# encoding: utf-8

require "digest/md5"
require 'carrierwave/processing/mini_magick'

class PrintAdUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:

  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # resize_to_fill, resize_to_limit, resize_to_fit
  version :thumb do
    process :resize_to_fill => [40, 40]
  end

  version :large do
    process :resize_to_fit => [40, 40]
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
