# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  include ErrorHandler

  protect_from_forgery with: :exception

  layout :user_layout

  # 用户登录后24小时内不做任何操作将自动退出
  MAX_SESSION_TIME = 60 * 60 * 24

  ADMIN_FILTERS = [:required_sign_in, :filter_out_shop_branch_sub_account, :require_wx_mp_user]

  before_filter :prepare_session, :set_current_user
  before_filter *ADMIN_FILTERS
  # before_filter :check_account_expire
  # before_filter :check_auth_mobile
  # before_filter :require_wx_mp_user

  helper_method :current_user, :services_config, :current_shop_account, :current_sub_account, :current_shop_branch
  helper_method :current_site, :mobile_subdomain, :mobile_domain

  private

  def prepare_session
    # return redirect_to 'http://www.winwemedia.com' if Rails.env.production? && request.host !~ /winwemedia\.com/

    if session[:expiry_time].present? and session[:expiry_time] < Time.now
      reset_session
    end

    session[:expiry_time] = MAX_SESSION_TIME.seconds.from_now

    return true
  end

  def current_user(force_reload = false)
    @current_user ||= if session[:account_id]
      Account.find(session[:account_id])
    elsif session[:sub_account_id]
      SubAccount.find(session[:sub_account_id])
    end
    @current_user.reload if force_reload
    @current_user
  end

  def current_site
    return unless current_user
    # @current_site ||= Site.find_by_id(session[:site_id]) || current_user.sites.create
    # @current_site ||= current_user.sites.where(id: session[:pc_site_id]).first || current_user.sites.create(name: current_user.nickname)
    @current_site ||= current_user.site || current_user.sites.create(name: current_user.nickname)
    session[:pc_site_id] = @current_site.id
    @current_site
  end

  def user_layout
    if current_user.is_a?(SubAccount) && current_user.shop_account?
      'micro_shop'
    else
      'application'
    end
  end

  def current_shop_account(force_reload = false)
    @current_shop_account ||= Account.find(session[:shop_account_id])
    @current_shop_account.reload if force_reload
    @current_shop_account
  end

  def current_sub_account
    @current_sub_account ||= current_shop_account.shop_branch_sub_accounts.find(session[:sub_account_id]) if session[:sub_account_id].present?
  end

  def current_shop_branch
    @current_shop_branch ||= current_sub_account.try(:user)
  end

  def mobile_subdomain(site_id = current_site.id)
    @mobile_subdomain = [site_id.to_s, MOBILE_SUB_DOMAIN].join('.')
  end

  def mobile_domain(site_id = current_site.id)
    @mobile_subdomain = [site_id.to_s, Settings.mhostname].join('.')
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
    Account.current = current_user
  end

  def clear_sign_in_session
    session[:account_id] = nil
    session[:sub_account_id] = nil
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
    @wx_mp_user = current_site.wx_mp_user || WxMpUser.create(account_id: current_user.id, site_id: current_site.id, nickname: current_user.nickname)
    # return redirect_to platforms_path, alert: '请先添加微信公共帐号' unless @wx_mp_user
  end

  def filter_out_shop_branch_sub_account
    redirect_to sign_in_path, alert: '您没有权限进行此操作！' and return false unless current_user.is_a?(Account)
  end

  def services_config
    @services_config ||= YAML.load_file(Rails.root.join("config", "services.yml")).fetch(Rails.env)
  end

  def check_account_expire
    # if current_user && current_user.normal_account? && current_user.expired? && !current_user.need_auth_mobile?
    #   return redirect_to console_url, alert: '您的账号使用期限已过，请联系客服进行续费。'
    # end
  end

  def check_auth_mobile
    if current_user && current_user.need_auth_mobile?
      redirect_to console_url, alert: '您的手机号还没验证，请先验证。'
    end
  end

  protected

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
