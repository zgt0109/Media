QINIU_CONFIG = YAML.load_file("#{Rails.root}/config/qiniu.yml")[Rails.env]

Qiniu.establish_connection! \
  :access_key => QINIU_CONFIG["access_key"],
  :secret_key => QINIU_CONFIG["secret_key"]


BUCKET_PICTURES = QINIU_CONFIG["bucket_pictures"]
BUCKET_VIEWS720 = QINIU_CONFIG["bucket_views720"]
BUCKET_MEDIA = QINIU_CONFIG["bucket_media"]
BUCKET_WMALL = QINIU_CONFIG["bucket_wmall"]
QINIU_DOMAIN = QINIU_CONFIG["domain"]
#QINIU_UPLOAD_TOKEN = Qiniu::RS.generate_upload_token scope: QINIU_BUCKET #can not use this ,it will expire

def qiniu_pictures_upload_token
  Qiniu.generate_upload_token scope: BUCKET_PICTURES
end
def qiniu_standalone_panorama_upload_token
  Qiniu.generate_upload_token scope: BUCKET_VIEWS720
end

module Qiniu
  module Storage
    class << self
      def chgm(bucket, key, mimetype)
        url = Config.settings[:rs_host] + '/chgm/' + encode_entry_uri(bucket, key) + '/mime/' + urlsafe_base64_encode(mimetype)
        return HTTP.management_post(url)
      end
    end
  end
end

module Qiniu
  class << self
    def chgm(bucket, key, mimetype)
      code, data = Storage.chgm(bucket, key, mimetype)
      code == StatusOK ? data : false
    end
  end
end

=begin
def generate_audio_upload_token
  Qiniu::RS.generate_upload_token \
    scope: QINIU_BUCKET_AUDIO,
    async_options: "avthumb/m3u8/preset/audio_32k;avthumb/wav/preset/audio_32k;avthumb/mp3/preset/audio_32k;avthumb/m3u8/preset/audio_64k;avthumb/wav/preset/audio_64k;avthumb/mp3/preset/audio_64k"
end
def generate_video_upload_token
  Qiniu::RS.generate_upload_token \
    scope: QINIU_BUCKET_VIDEO,
    async_options: "avthumb/m3u8/preset/video_16x9_150k;avthumb/m3u8/preset/video_16x9_640k;avthumb/mp4/preset/video_16x9_150k;avthumb/flv/preset/video_16x9_150k;avthumb/flv/preset/video_16x9_640k;avthumb/mp4/preset/video_16x9_640k;avthumb/ogg/preset/video_16x9_150;avthumb/ogg/preset/video_16x9_640k;avthumb/m4v/preset/video_16x9_150;avthumb/m4v/preset/video_16x9_640k;avthumb/webm/preset/video_16x9_150;avthumb/webm/preset/video_16x9_640k"
end

QINIU_ENTRYURI = "testimages:eePG33EPxBQEYeuPbzQ8siZfi-pklcvzocOt1XPm"
QINIU_ENCODEDENTRYURI = Base64.urlsafe_encode64 QINIU_ENTRYURI
QINIU_UPLOAD_ACTION = "/rs-put/#{QINIU_ENCODEDENTRYURI}"
=end
