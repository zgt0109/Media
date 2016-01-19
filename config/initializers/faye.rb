# FAYE_HOST = "localhost:9393"
FAYE_HOST = if Rails.env.production?
  "m.winwemedia.com:9393"
elsif Rails.env.staging?
  "m.winwemedia.com:9393"
else
  "localhost:9393"
end
