# encoding: utf-8

require "digest/md5"
require 'streamio-ffmpeg'
# require 'carrierwave/processing/mini_magick'

class GreetVoiceUploader < CarrierWave::Uploader::Base
  include CarrierWave::Video
  CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/

  storage :file

  # process encode_video: [:mp3, :custom => '-ab 128k']

  def store_dir
    "uploads/greet_voice/#{model.class.to_s.underscore}/#{mounted_as}"
  end

  version :mp3 do
    process :encode_video => [:mp3]
    def full_filename (for_file = model.audio.file.filename)
      for_file[0...for_file.rindex('.')] + '.mp3'
    end
  end

  version :ogg do
    process :encode_video => [:ogg]
    def full_filename (for_file = model.audio.file.filename)
      for_file[0...for_file.rindex('.')] + '.ogg'
    end
  end

end
