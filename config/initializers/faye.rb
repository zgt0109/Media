# FAYE_HOST = "localhost:9393"
FAYE_HOST = if Rails.env.production?
  "wx.winwemedia.com:9393"
elsif Rails.env.staging?
  "wx.winwemedia.com:9393"
else
  "localhost:9393"
end
