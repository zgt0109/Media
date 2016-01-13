class MerchantApp::DevLogsController < Api::V1::BaseController
  layout 'merchant_app'
  before_filter :require_account

end