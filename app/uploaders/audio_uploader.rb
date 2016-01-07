# encoding: utf-8

require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class AudioUploader < CarrierWave::Uploader::Base

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  def store_dir
    "uploads/audios/#{model.class.to_s.underscore}/#{mounted_as}"
  end

end
