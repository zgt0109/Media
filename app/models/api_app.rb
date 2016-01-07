class ApiApp < ActiveRecord::Base

  class << self
    def bqq
      bqq_app_id = Rails.env.production? ? 10001 : 10002
      ApiApp.where(id: bqq_app_id).first
    end

    def baidu
      ApiApp.where(id: 10003).first
    end

    def yeahsite
      ApiApp.where(id: 10004).first
    end
  end

  def token_expired?
    return true if expires_at.blank?

    Time.now >= expires_at
  end

  def fetch_baidu_token(options = { refresh: false })
    # return unless token_expired?

    api_app = ApiApp.baidu

    url = URI::encode("https://openapi.baidu.com/oauth/2.0/token")
    params = {
      grant_type: 'client_credentials',
      app_id: api_app.app_id,
      app_secret: api_app.app_secret,
    }
    if options[:refresh] && api_app.refresh_token.present?
      params.merge!(refresh_token: api_app.refresh_token, grant_type: 'refresh_token')
    end
    # puts "request params: #{params}"

    result = RestClient.post(url, params)
    data = JSON(result)
    puts "fetch_baidu_token data: #{data}"

    if data['access_token']
      api_app.update_attributes(
        access_token: data['access_token'], 
        refresh_token: data['refresh_token'], 
        expires_at: Time.now+data['expires_in'].to_i, 
        description: data
      )
      return true
    else
      return false
    end
  rescue => error
    # puts "fetch_baidu_token error: #{error}"
    WinwemediaLog::BqqApi.add("fetch_baidu_token error: #{error.message} -> #{error.backtrace}")
    return false
  end

  def fetch_bqq_token
    # return unless token_expired?

    api_app = ApiApp.bqq
    url = URI::encode("https://api.b.qq.com/crm/token?appid=#{api_app.app_id}&secret=#{api_app.app_secret}")
    result = RestClient.get(url)
    data = JSON(result)
    puts "fetch_bqq_token data: #{data}"

    if data['access_token']
      api_app.update_attributes(access_token: data['access_token'], expires_at: Time.now+data['expires_in'].to_i, description: data)
      return true
    else
      return false
    end
  rescue => error
    # puts "fetch_bqq_token error: #{error}"
    WinwemediaLog::BqqApi.add("fetch_bqq_token error: #{error.message} -> #{error.backtrace}")
    return false
  end

end
