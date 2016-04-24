# -*- encoding : utf-8 -*-
class AccountsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, only: [:new, :create]
  before_filter :set_account, only: [:edit, :update_mobile, :update]
  skip_before_filter :check_auth_mobile, only: [:send_sms, :update_mobile]

  def index
    @partialLeftNav = "/layouts/partialLeftSys"
    render layout: 'application'
  end

  def new
    @account = Account.new(account_type: Account::TRIAL_ACCOUNT)
    render layout: "com"
  end

  def create
    @account = Account.new(params[:account])
    # return render json: {code: -4, message: "图形验证码错误!", num: 3, status: 0}  if session[:image_code] and session[:image_code] != params[:verify_code]
    # return render json: {code: -3, message: "手机号或验证码错误!", num: 6, status: 0} if params[:account][:mobile].blank? || params[:account][:mobile] != session[:mobile]
    # return render json: {code: -1, message: "验证码错误!", num: 6, status: 0} if params[:captcha].blank? || params[:captcha].to_i != session[:captcha].to_i
    unless verify_rucaptcha?(params)
      return render json: {code: -1, message: "验证码错误!", num: 3, status: 0}
    end

    if @account.save
      # @account.update_attributes(auth_mobile: 1)
      # if params[:account][:mobile].present? && params[:account][:mobile].length == 11 && Rails.env.production?
      #   SmsService.new.singleSend(params[:account][:mobile],"#{params[:account][:contact]} 先生/女士，感谢您注册！帐号#{params[:account][:nickname]}，密码#{params[:account][:password]}，体验时间30天。请在电脑上登录 微枚迪官网 进行设置、绑定公众号，在手机上浏览效果。如遇困难，请联系4000-365-711。祝生活愉快！")  #发送短信
      # end

      session[:account_id] = @account.id
      @account.update_sign_in_attrs_with(request.remote_ip)

      # 初始化公众号和微官网
      # @wx_mp_user = @account.create_wx_mp_user!(name: current_user.nickname)
      # @wx_mp_user = WxMpUser.where(account_id: @account.id).first_or_create(name: @account.nickname)
      # @wx_mp_user.create_activity_for_website

      # @account.delay.init_website_data
      # WebsiteInitWorker.perform_async(@account.id)

      return render json: {code: 0, message: "注册成功!", num: 6, status: 1}
    else
      logger.error @account.errors.messages
      # return render json: {code: -2, message: "保存出错!"}
      return render json: {code: -2, message: @account.errors.messages.map{|k,v| "#{k}:#{v.keep_if{|v| v.present?}.join(',')}"}.join("; ") }
    end

  rescue => e
    logger.error "#{e.message}:#{e.backtrace}"
    return render json: {code: -9, message: e.message, num: 6, status: 0}
  end

  def update
    if @account.update_attributes(params[:account])
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: "更新失败，#{@account.errors.full_messages.join(",")}"
    end
  end

  def edit
    @partialLeftNav = "/layouts/partialLeftSys"
    render layout: 'application'
  end

  def send_sms
    # return render json: { errcode: -1 } if session[:image_code].blank? || params[:verify_code].blank? || session[:image_code] != params[:verify_code]

    session[:captcha], session[:mobile] = rand(100000..999999).to_s, params[:mobile].to_s
    SmsAlidayu.new.send_code_for_verify(session[:mobile], session[:captcha])
    render json: { errcode: 0 }
  end

  def update_mobile
    return redirect_to :back, alert: '更新失败，请重新获取验证码验证' if params[:account][:mobile] != session[:mobile]
    return redirect_to :back, alert: '验证码错误' if params[:captcha] != session[:captcha]

    if @account.update_attributes(auth_mobile: 1, mobile: params[:account][:mobile])
      redirect_to :back, notice: '验证成功'
    end
  end

  private
    def set_account
      @account = current_user
    end
end
