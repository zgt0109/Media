class TempfileFactory

  def generate(name = random_name)
    @name = name
    file = Tempfile.new([basename, extension])
    file.binmode
    file
  end

  def extension
    File.extname(@name)
  end

  def basename
    Digest::MD5.hexdigest(File.basename(@name, extension))
  end

  def random_name
    SecureRandom.uuid
  end
end


module Kefu
  class ApiController < ApplicationController
    skip_before_filter *ADMIN_FILTERS, :set_current_user, :promotion_code_tracking
    def index
      token = params[:kefu_token]
      wx_mp_user = WxMpUser.where(kefu_token: token).first
      wx_user = WxUser.where(uid: params[:touser]).first
      if params[:type] == 'send'
        send_message(wx_mp_user, params[:touser], params[:text][:content])
      end
      if params[:type] == 'normal'
        wx_user.normal!
      end
      if params[:type] == 'kefu'
        wx_user.kefu!
      end
      if params[:type] == 'rate'
        wx_user.kefu_rate!
      end
      if params[:type] == 'upload_media'
        result = upload_media(wx_mp_user)
        render json: result and return
      end
      if params[:type] == 'upload_mpnews'
        result = upload_mpnews(wx_mp_user)
        render json: result and return
      end
      if params[:type] == 'mass_send'
        result = mass_send(wx_mp_user)
        render json: result and return
      end
      if params[:type] == 'update_code'
        result = update_kefu_code(wx_mp_user, params[:code])
        render json: result and return
      end
      render json: { errcode: 0, errmsg: '' } and return
    end

    WX_BASE_URL = 'https://api.weixin.qq.com/cgi-bin/'
    def send_message(wx_mp_user, toUser, content)
      wx_mp_user.auth!

      return if wx_mp_user.access_token.blank?

      message_api = WX_BASE_URL + 'message/custom/send?access_token=' + wx_mp_user.access_token
      data = {
        msgtype: 'text',
        touser: toUser,
        text: {
          content: content
        }
      }
      res = RestClient.post( message_api, JSON(data) ) rescue {}
      JSON.parse res
    end

    def upload_media(wx_mp_user)
      wx_mp_user.auth!
      media_file = params[:media]
      destination = TempfileFactory.new.generate(media_file.original_filename.to_s)
      FileUtils.cp(media_file.tempfile.path, destination.path)

      upload_api = WX_BASE_URL + 'media/upload?access_token='+wx_mp_user.access_token
      data = {
        type: params[:media_type],
        media: File.new(destination.path)
      }
      res = RestClient.post(upload_api, data) rescue {}
      JSON.parse(res)
    end

    def upload_mpnews(wx_mp_user)
      wx_mp_user.auth!
      mpnews_api = WX_BASE_URL + 'media/uploadnews?access_token='+wx_mp_user.access_token
      data = {
        'articles' => params[:articles]
      }
      res = RestClient.post(mpnews_api, data.to_json) rescue {}
      JSON.parse(res)
    end

    def mass_send(wx_mp_user)
      wx_mp_user.auth!
      mass_send_api = WX_BASE_URL + 'message/mass/send?access_token='+wx_mp_user.access_token
      data = {
        "touser" => params[:touser],
        "mpnews" => params[:mpnews],
        "msgtype" => params[:msgtype]
      }
      res = RestClient.post(mass_send_api, data.to_json) rescue {}
      JSON.parse(res)
    end

    def update_kefu_code(wx_mp_user, code)
      return {} unless wx_mp_user
      wx_mp_user.update_attribute(:kefu_js_code, code) if code.present?
      {}
    end
  end
end

