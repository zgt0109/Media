module WxReplyMessage

  def wlife_admin_root_url(auth_token=nil)
    "#{WLIFE_HOST}/business?auth_token=#{auth_token}"
  end

  def wlife_website_root_url(auth_token=nil)
    "#{WLIFE_HOST}/pro/websites?auth_token=#{auth_token}"
  end

end

