
if File.exists?("#{Rails.root}/config/payment_config.yml")
  PAYMENT_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/payment_config.yml")[Rails.env] || {})
end

WSHOP_HOST         = Settings.wshop_host
WMALL_HOST         = Settings.wmall_host
WLIFE_HOST         = Settings.wlife_host
SHEQU_HOST         = Settings.shequ_host
PANORAMA_FAYE_HOST = Settings.faye_host
RECOMMEND_HOST     = Settings.recommend_host
HOTEL_HOST         = Settings.hotel_host
OA_HOST            = Settings.oa_host
MERCHANT_APP_HOST  = Settings.app_host

M_HOST             = "http://#{Settings.mhostname}"
WWW_HOST           = "http://#{Settings.hostname}"

# 常用变量声明
MOBILE_SUB_DOMAIN = Settings.mhostname.sub(/\.[com|dev].?/, '').split('.')[0..-2].join('.')

EXPORTING_COUNT = 2000

TEST_USER_ID = Rails.env.production? ? 10004 : nil

# kefu
if Rails.env.production?
  url = "http://kf.winwemedia.com"
else
  url = "http://kefu.winwemedia.com"
end
KEFU_URL = url