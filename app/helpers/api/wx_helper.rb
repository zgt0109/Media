module Api::WxHelper
  def wx_config(wx_mp_user, url)
    return {} unless wx_mp_user

    config = {}
    url = CGI.unescape(url)
    url = url.split('#').first
    config['timestamp'] = Time.now.to_i
    config['noncestr'] = SecureRandom.urlsafe_base64
    config['jsapi_ticket'] = wx_mp_user.get_wx_jsapi_ticket

    query_string = Hash[config.sort].to_query + "&url="+ url
    config['signature'] = Digest::SHA1.hexdigest(query_string)
    config['app_id'] = wx_mp_user.app_id
    config['url'] = url
    config
  end

  def generate_wx_share_options(base_url, path, query_parameters, image_url, openid)
    query_parameters.delete('openid')

    openid_params = { origin_openid: openid }
    openid_params.merge!(owner_openid: openid) if query_parameters[:owner_openid].blank?

    link_url = base_url+ path + '?' + query_parameters.merge(openid_params).to_query

    logger.info "================== jsapi_ticket url #{link_url}"

    image_url = "http://#{Settings.mhostname}#{@share_image.to_s}" unless /^(http|https):\/\/[a-zA-Z0-9].+$/ =~ image_url

    { link_url: link_url, image_url: image_url }
  end
end

