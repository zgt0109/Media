class Api::V1::WxController < Api::BaseController
  include Api::WxHelper

  before_filter :cors_set_access_control_headers
  before_filter :find_objects, only: [:jsapi_config]

  # http://www.winwemedia.com/v1/wx/token?app_id=111
  def token
    return render json: {} if params[:app_id].blank?

    wx_mp_user = WxMpUser.where(app_id: params[:app_id]).first
    if wx_mp_user
      wx_mp_user.auth!(true) if wx_mp_user.auth_expired?

      render json: {
        app_id: wx_mp_user.app_id,
        access_token: wx_mp_user.access_token.to_s,
        expires_in: wx_mp_user.expires_in.to_s
      }
    else
      render json: {}
    end
  end

  # 请求微信JsApi配置接口，输入参数: auth_token, url
  # 成功返回:
  # { errcode: 0,
  #   config: {
  #      timestamp: timestamp, // 生成签名的时间戳
  #      nonce_str: nonce_str, // 生成签名的随机串
  #      signature: signature, // 签名
  #      app_id: app_id // 公众号的唯一标识
  #   }
  # }
  # demo: http://m.winwemedia.com/v1/wx/jsapi_config?url=http://www.baidu.com&auth_token=9MoZzBC71HddLw-_UH5zBQfCjBcQErp8TQho6cRHxqY17BiEX64ZS_nw97SYa8Jwk4i1Wd5hr6uKG4x2

  def jsapi_config
    render json: { errcode: 0, config: wx_config(@wx_mp_user, @url) }
  end

  private
    def find_objects
      @url = params[:url]
      return render json: { errcode: 1, errmsg: "missing attributes: url" }, status: 400 unless @url.present?

      if params[:auth_token].present?
        @supplier = Account.where(auth_token: params[:auth_token]).first
        @wx_mp_user = @supplier.try(:wx_mp_user)
      elsif params[:app_id].present?
        @wx_mp_user = WxMpUser.where(app_id: params[:app_id]).first
        @supplier = @wx_mp_user.try(:supplier)
      end

      return render json: { errcode: 3, errmsg: "wx_mp_user not found" }, status: 404 unless @wx_mp_user.present?
    end

    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = '*'
      headers['Access-Control-Allow-Headers'] = '*'
    end

end
