class Pay::BaseController < ApplicationController
  # before_filter :require_wx_mp_user,  :require_privilege
  before_filter :fetch_pay_account, expect: [:conditions]

  before_filter do
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  private

  def fetch_pay_account
    @pay_account = current_user.pay_account
    redirect_to pay_accounts_path unless @pay_account# && (current_user.normal? || current_user.freeze?)
  end

  def require_privilege
    redirect_to console_url, alert: '体验账号没有权限使用此功能，请联系代理商升级为正式账号再申请。' unless current_user.normal_account?
  end
end
