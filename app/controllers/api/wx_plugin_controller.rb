class Api::WxPluginController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, :verify_authenticity_token
  before_filter :decrypt_string, only: :ticket

  def ticket
    if @xml['ComponentVerifyTicket'].present?
      $redis.set(WxPluginService::VERIFY_TICKET_KEY, @xml['ComponentVerifyTicket'])
      WxPluginService.fetch_component_access_token
    elsif @xml['InfoType'].eql?('unauthorized') && @xml['AuthorizerAppid'].present?
      mp_user = WxMpUser.where(app_id: @xml['AuthorizerAppid']).first
      if mp_user
        if mp_user.code.present? & mp_user.token.present?
          mp_user.update_attributes(bind_type: 1)
        else
          mp_user.update_attributes(bind_type: -1)
        end
      end
    end
    render text: 'success'
  end

  def auth
    if params[:auth_code].present?
      wx_mp_user = WxPluginService.fetch_wx_mp_user_api_auth(params[:auth_code], current_user)
      if wx_mp_user.blank?
        @error = '绑定失败！'
      else
        session[:account_id] = wx_mp_user.site.account_id
      end
    else
      @error = '绑定失败！'
    end
    redirect_to platforms_path, notice: @error || '绑定成功'
  end

  private
    def check_signature
      checked = check_signatrue?(Settings.wx_plugin.token, params[:signature], params[:timestamp], params[:nonce])
      render text: '签名验证失败' and return false unless checked
    end

    def check_signatrue?(token, signature, timestamp, nonce)
      return false if token.blank?

      signature == Digest::SHA1.hexdigest([token.to_s, timestamp.to_s, nonce.to_s].sort.join)
    end

    def decrypt_string
      aes_key           = Base64.decode64(Settings.wx_plugin.encoding_aes_key + '=')
      aes_encoded_msg   = Base64.decode64(params[:xml][:Encrypt])

      de_cipher         = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
      de_cipher.decrypt
      de_cipher.padding = 7
      de_cipher.key     = aes_key
      de_cipher.iv      = aes_key[0, 16]
      str               = de_cipher.update(aes_encoded_msg).strip

      last_right_angle_index = str.rindex('>')
      hash = HashWithIndifferentAccess.new(Hash.from_xml(str[20..last_right_angle_index]))

      @xml = hash['xml']
    end
end
