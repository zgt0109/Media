module WxReplyMessage

  def shequ_admin_root_url(auth_token=nil)
    "#{SHEQU_HOST}?auth_token=#{auth_token}"
  end

end