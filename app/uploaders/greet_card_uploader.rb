# encoding: utf-8

require "digest/md5"
require 'carrierwave/processing/mini_magick'

class GreetCardUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  process :convert => 'png'

  version :large do
    process :resize_to_fit => [1024,266]
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