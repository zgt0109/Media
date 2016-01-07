class Biz::WinwemediaPayController < ApplicationController
	before_filter :require_wx_mp_user,  :require_privilege
	before_filter :fetch_supplier_account, expect: [:conditions]

	before_filter do
    @partialLeftNav = "/layouts/partialLeftSys"
  end

	private

	def fetch_supplier_account
		@supplier_account = current_user.supplier_account
		redirect_to supplier_accounts_path unless @supplier_account && (@supplier_account.normal? || @supplier_account.freeze?)
	end

  def require_privilege
    redirect_to console_url, alert: '体验账号没有权限使用此功能，请联系代理商升级为正式账号再申请。' unless current_user.normal_account?
  end
end
