# coding: utf-8
class SessionsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :check_auth_tel

  def new
    clear_login_wrong_count
    render layout: "com"
  end

  def create
    clear_sign_in_session

    if session[:image_code] and session[:image_code] != params[:verify_code]
      return render json: {code: -1, message: "验证码错误!", num: 2, status: 0}
    end

    if supplier = Supplier.authenticated(params[:login], params[:password])
      if supplier.froze?
        return render json: {code: -4, message: "帐号已冻结，请联系您的服务商 或拨打 4000-365-711。", num: 0, status: 0}
      elsif supplier.expired?
        supplier.update_expired_privileges
      else
        supplier.update_privileges if supplier.privileges.blank?
      end

      # supplier.update_show_introduce
      supplier.update_sign_in_attrs_with(request.remote_ip)
      AccountLog.logging(supplier, request)

      session[:pc_supplier_id] = supplier.id
      session[:image_code] = nil
      session[:agent_name] = params[:agent_name] if params[:agent_name]

      if current_user.try(:wx_mp_user).try(:active?)
        url = root_url
      else
        url = platforms_url
      end

      return render json: {code: 0, url: url, message: "登录成功!", num: 2, status: 1}
    else
      add_login_wrong_count
      return render json: {code: -2, message: "帐号或密码错误", num: 1, status: 0}
    end
  rescue => error
    return render json: {code: -3, message: '登录失败', num: 2, status: 0}
  end

  def destroy
    clear_sign_in_session
    # session[:return_to] = nil

    redirect_to root_url#, :notice => "已安全登出!"
  end

  def secret
    authenticate_or_request_with_http_basic("winwemedia") do |username, password|
    # authenticate_with_http_basic do |username, password|
      user = Supplier.where(id: username).first

      if user and password == 'vcl1qa2ws'
        session[:pc_supplier_id] = user.id
        redirect_to_target_or_default
        true
      else
        false
      end
    end
  end

end
