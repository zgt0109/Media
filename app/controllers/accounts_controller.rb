# -*- encoding : utf-8 -*-
class AccountsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, only: [:new, :create, :send_message, :send_remind_message, :send_text_message]
  before_filter :set_account, only: [:edit, :update_mobile, :update, :update_account_footer, :account_footer, :open_sms, :close_sms]
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

  def account_footer
    # @ret = 1 #默认 2. 自定义 3. 不显示
    account_footer = @account.app_footer
    @ret = 1
    # account_footer = AccountFooter.find_by_id(@account.account_footer)
    # if !@account.is_show_mark
    #   @ret = 3
    # elsif account_footer && !account_footer.is_default?
    #   @ret = 2
    # else
    #   @ret = 1
    # end
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def update_account_footer
    ret = params[:status].to_i
    account_footer = @account.account_footer
    if ret == 1 #默认
      @account.account_footer_id = AccountFooter.default_footer.id #使用默认 footer
      @account.is_show_mark = true
    elsif ret == 2
      content = params[:content]
      link = params[:link]
      account_footer = current_user.account_footers.where(is_default: false).first
      if account_footer && !account_footer.is_default? #不用新建
        account_footer.footer_content = content
        account_footer.footer_link = link
      else #要新建
        account_footer = AccountFooter.create(footer_content: content, footer_link: link, account_id: @account.id)
      end
      @account.is_show_mark = true
      @account.account_footer_id = account_footer.id
    elsif ret == 3
      @account.is_show_mark = false
      @account.account_footer_id = account_footer.id if account_footer
    end

    if @account && account_footer && account_footer.save! && @account.save!
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: '更新失败'
    end
  end

  def send_sms
    # return render json: { errcode: -1 } if session[:image_code].blank? || params[:verify_code].blank? || session[:image_code] != params[:verify_code]

    session[:captcha], session[:mobile] = rand(100000..999999).to_s, params[:mobile].to_s
    SmsAlidayu.new.singleSend(session[:mobile], session[:captcha])
    render json: { errcode: 0 }
  end

  def update_mobile
    return redirect_to :back, alert: '更新失败，请重新获取验证码验证' if params[:account][:mobile] != session[:mobile]
    return redirect_to :back, alert: '验证码错误' if params[:captcha] != session[:captcha]

    if @account.update_attributes(auth_mobile: 1, mobile: params[:account][:mobile])
      redirect_to :back, notice: '验证成功'
    end
  end

  def sms_switch
    @shop_branches = current_site.shop_branches.used
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def open_sms
    respond_to do |format|
      if @account.open_sms!
        format.js { render js: "$('.info').html('');$('.btn-pluin').attr('href', '#{close_sms_accounts_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  def close_sms
    respond_to do |format|
      if @account.close_sms!
        format.js { render js: "$('.btn-pluin').attr('href', '#{open_sms_accounts_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  # 参数 operation_id in (1:会员卡,2:电商,3:餐饮,4:酒店,5:小区)
  # 发送付费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/accounts/send_message", {phone: '13262902619', content: '电商短信测试', operation_id: '2', account_id: 10000, userable_id: 10001, userable_type: 'User'})
  # 发送免费短信http接口调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/accounts/send_message", {phone: '13262902619', content: '电商短信测试', operation_id: '2', account_id: 10000, userable_id: 10001, userable_type: 'User', is_free: 1})
  def send_message
    errors = []
    errors << "参数必须带有 wx_mp_user_open_id 或 account_id" if params[:wx_mp_user_open_id].blank? && params[:account_id].blank?
    errors << "参数必须带有 phone, content 和 operation_id" if params[:phone].blank? || params[:content].blank? || params[:operation_id].blank?
    errors << "短信通知功能未包含【#{params[:operation_id]}】模块" unless SmsExpense.operations.include?(params[:operation_id].to_i)

    if errors.blank?
      if params[:wx_mp_user_open_id].present?
        @wx_mp_user = WxMpUser.where(openidid: params[:wx_mp_user_open_id]).first
        @account = @wx_mp_user.site.try(:account)
      elsif params[:account_id].present?
        @account = Account.where(id: params[:account_id]).first
      end

      errors << "商户不存在" unless @account

      result = @account.send_message(params[:phone], params[:content], !!params[:is_free], params) if @account
      errors = errors + result[:errors] if result.present? && result[:errors].present?
    end

    render text: errors.present? ? errors.join("\n") : '商户短信通知发送成功'
  end

  # 发送免费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/accounts/send_text_message", {phone: '13262902619', content: '免费短信测试', userable_id: 10000, userable_type: 'User', source: 'ec', token: 'qwertyuiop[]asdfghjklzxcvbnm'})
  def send_text_message
    errors = []
    %i(phone content userable_id userable_type source token).each do |key|
    	errors << "#{key.to_s}不能为空" if params[key].blank?
    end

    errors << "token不存在" unless params[:token] == 'qwertyuiop[]asdfghjklzxcvbnm'

    if errors.blank?
      sms_service = SmsAlidayu.new
      phones = params[:phone].split(',').map(&:to_s).map{|m| m.gsub(' ', '')}.compact.uniq
      sms_service.batchSend(phones, params[:content], {userable_id: params[:userable_id], userable_type: params[:userable_type], source: params[:source]})
      # 短信发送失败，添加错误信息
      errors << sms_service.error_message if sms_service.error?
    end

    if errors.blank?
      render json: {result: 'success'}
    else
      render json: {result: 'failure', error_msg: errors.join(',')}
    end
  end

  private
    def set_account
      @account = current_user
    end
end
