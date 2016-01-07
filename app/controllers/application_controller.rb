# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  include ErrorHandler
  layout :user_layout
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # 用户登录后24小时内不做任何操作将自动退出
  MAX_SESSION_TIME = 60 * 60 * 24

  ADMIN_FILTERS = [:required_sign_in, :filter_out_shop_branch_sub_account]

  before_filter :prepare_session, :set_current_user, :promotion_code_tracking
  before_filter *ADMIN_FILTERS
  before_filter :check_account_expire
  # before_filter :check_auth_tel

  helper_method :current_user, :services_config, :current_shop_supplier, :current_sub_account, :current_shop_branch

  private

  def prepare_session
    return redirect_to 'http://www.winwemedia.com' if Rails.env.production? && request.host !~ /winwemedia\.com/

    if session[:expiry_time].present? and session[:expiry_time] < Time.now
      # Session has expired. Clear the current session.
      reset_session
    end

    # Assign a new expiry time, whether the session has expired or not.
    session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now

    clear_sign_in_session if (session[:pc_supplier_id] == TEST_USER_ID && session[:sub_account_id].nil? )
    return true
  end

  def current_user(force_reload = false)
    @current_user ||= if session[:pc_supplier_id]
      Supplier.find(session[:pc_supplier_id])
    elsif session[:sub_account_id]
      SubAccount.find(session[:sub_account_id])
    end
    @current_user.reload if force_reload
    @current_user
  end

  def user_layout
    if current_user.is_a?(SubAccount) && current_user.shop_account?
      'micro_shop'
    else
      'application'
    end
  end

  def current_shop_supplier(force_reload = false)
    @current_shop_supplier ||= Supplier.find(session[:shop_supplier_id])
    @current_shop_supplier.reload if force_reload
    @current_shop_supplier
  end

  def current_sub_account
    @current_sub_account ||= current_shop_supplier.shop_branch_sub_accounts.find(session[:sub_account_id]) if session[:sub_account_id].present?
  end

  def current_shop_branch
    @current_shop_branch ||= current_sub_account.try(:user)
  end

  def required_sign_in
    unless current_user
      if action_name == 'console'
        return redirect_to '/'
      end
      flash[:alert] = "你还没有登录，请先登录..."
      store_location
      redirect_to sign_in_path
    end
  end

  def set_current_user
    Supplier.current = current_user
  end

  def clear_sign_in_session
    session[:pc_supplier_id] = nil
    session[:promotion_code] = nil
    session[:agent_name]     = nil
    session[:sub_account_id] = nil
    session[:first_sign_in] = nil
  end

  def add_login_wrong_count
    session[:add_login_wrong_count] ||= 0
    session[:add_login_wrong_count] = session[:add_login_wrong_count] + 1
  end

  def clear_login_wrong_count
    session[:add_login_wrong_count] = nil
  end

  def store_location
    # session[:return_to] = request.referrer
    session[:return_to] = request.path unless request.path == '/'
  end

  def redirect_to_target_or_default(default = '/', *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end

  def deny_access
    flash[:alert] = "您没有权限进行此操作！如有问题请与技术部联系."
    redirect_to_target_or_default
  end

  def require_wx_mp_user
    @wx_mp_user = current_user.wx_mp_user
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user
  end

  def restrict_trial_supplier
    # redirect_to :back, alert: "无法操作：您的账户为试用账户，请购买专业版。" if current_user.trial_account?
  end

  def filter_out_shop_branch_sub_account
    redirect_to sign_in_path, alert: '您没有权限进行此操作！' and return false unless current_user.is_a?(Supplier)
  end

  def promotion_code_tracking
    session[:promotion_code] = params[:source] if params[:source]
  end

  def services_config
    @services_config ||= YAML.load_file(Rails.root.join("config", "services.yml")).fetch(Rails.env)
  end

  def check_account_expire
    if current_user && current_user.normal_account? && current_user.expired? && !current_user.need_auth_tel?
      return redirect_to console_url, alert: '您的账号使用期限已过，请联系您的代理商进行续费 或拨打 4000-365-711。'
    end
  end

  def check_auth_tel
    if current_user && current_user.need_auth_tel?
      redirect_to console_url, alert: '您的手机号还没验证，请先验证。'
    end
  end

  protected

    def ckeditor_filebrowser_scope(options = {})
      super({ :assetable_id => current_user.id, :assetable_type => 'Supplier' }.merge(options))
    end

    # Set current_user as assetable
    def ckeditor_before_create_asset(asset)
      asset.assetable = current_user
      return true
    end

    def render_with_alert(template, message, options = {})
      flash.alert = message
      render template, options
    end

    def render_with_notice(template, message, options = {})
      flash.notice = message
      render template, options
    end

    def valid_verify_code?( code )
      image_code = session.delete( :image_code )
      image_code && image_code == code
    end
end
