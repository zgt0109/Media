# encoding: utf-8

require "digest/md5"
# require 'carrierwave/processing/mini_magick'

class VideoUploader < CarrierWave::Uploader::Base
  # include CarrierWave::Video
  # process encode_video: [:mp4, callbacks: { after_transcode: :set_success } ]

  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  def store_dir
    "uploads/videos/#{model.class.to_s.underscore}/#{mounted_as}"
  end

end
