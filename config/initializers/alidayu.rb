# module Alidayu
#   Sms = AlidayuSmsSender.new
# end

Alidayu.setup do |config|
  config.server     = 'http://gw.api.taobao.com/router/rest'
  config.app_key    = '23331392'
  config.app_secret = '05c18d9ff0b7d7f30eabb901f7c303ac'
  config.sign_name  = '微枚迪'
end