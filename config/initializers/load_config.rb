
if File.exists?("#{Rails.root}/config/payment_config.yml")
  PAYMENT_CONFIG = HashWithIndifferentAccess.new(YAML.load_file("#{Rails.root}/config/payment_config.yml")[Rails.env] || {})
end

HOST_CONFIG        = YAML.load_file("#{Rails.root}/config/host_config.yml")[Rails.env]

WSHOP_HOST         = HOST_CONFIG['wshop_host']
WMALL_HOST         = HOST_CONFIG['wmall_host']
WLIFE_HOST         = HOST_CONFIG['wlife_host']
PANORAMA_FAYE_HOST = HOST_CONFIG['faye_host']
RECOMMEND_HOST     = HOST_CONFIG['recommend_host']
HOTEL_HOST         = HOST_CONFIG['hotel_host']
OA_HOST            = HOST_CONFIG['oa_host']
MERCHANT_APP_HOST  = HOST_CONFIG['merchant_app_host']

M_HOST             = "http://#{Settings.mhostname}"
WWW_HOST           = "http://#{Settings.hostname}"

# 常用变量声明
APP_SUB_DOMAIN = Settings.mhostname.sub(/\.[com|dev].?/, '').split('.')[0..-2].join('.')

WEBSITE_DOMAIN = "http://#{Settings.hostname}"
MOBILE_DOMAIN  = "http://#{Settings.mhostname}"

EXPORTING_COUNT = 2000

TEST_USER_ID = Rails.env.production? ? 76477 : nil

# kefu
if Rails.env.production?
  url = "http://kf.winwemedia.com"
else
  url = "http://kefu.winwemedia.com"
end
KEFU_URL = url