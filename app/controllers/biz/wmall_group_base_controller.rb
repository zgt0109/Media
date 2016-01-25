class Biz::WmallGroupBaseController < Biz::GroupBaseController
  skip_before_filter :sso_by_cas, :required_sign_in, :set_current_site, :filter_out_shop_branch_sub_account, :require_group
  before_filter :login_from_api, :require_sign_in_for_group, :cors_set_access_control_headers

  private

  def require_sign_in_for_group
    unless current_site
      flash[:alert] = "你还没有登录，请先登录..."
      store_location
      redirect_to sign_in_path
    end
  end

  def login_from_api
    if params[:auth_token].present?
      account = Account.where(auth_token: params[:auth_token]).first
      if account
        session[:account_id] = account.id
        require_group
      end
    end
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
  end

end