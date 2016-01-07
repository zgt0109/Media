# -*- encoding : utf-8 -*-
class SuppliersController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, only: [:new, :create, :send_message, :send_remind_message, :send_text_message]
  before_filter :set_supplier, only: [:edit, :update_tel, :update, :update_supplier_footer, :supplier_footer, :open_sms, :close_sms]
  skip_before_filter :check_auth_tel, only: [:send_sms, :update_tel]

  def new
    @supplier = Supplier.new(is_reg_web: true, account_type: Supplier::TRIAL_ACCOUNT)
    render layout: "com"
  end

  def create
    @supplier = Supplier.new(params[:supplier])
    return render json: {code: -4, message: "图形验证码错误!", num: 3, status: 0}  if session[:image_code] and session[:image_code] != params[:verify_code]
    return render json: {code: -3, message: "手机号或验证码错误!", num: 6, status: 0} if params[:supplier][:tel].blank? || params[:supplier][:tel] != session[:mobile]
    return render json: {code: -1, message: "验证码错误!", num: 6, status: 0} if params[:captcha].blank? || params[:captcha].to_i != session[:captcha].to_i

    if @supplier.save
      @supplier.update_attributes(auth_tel: 1)
      if params[:supplier][:tel].present? && params[:supplier][:tel].length == 11 && Rails.env.production?
        SmsService.new.singleSend(params[:supplier][:tel],"#{params[:supplier][:contact]} 先生/女士，感谢您注册！帐号#{params[:supplier][:nickname]}，密码#{params[:supplier][:password]}，体验时间30天。请在电脑上登录 微枚迪官网 进行设置、绑定公众号，在手机上浏览效果。如遇困难，请联系4000-365-711。祝生活愉快！")  #发送短信
      end
      if @supplier.is_reg_web #申请注册成功后，直接跳转到产品后台，并为登陆状态，进入初次登陆微枚迪流程
        session[:pc_supplier_id] = @supplier.id
        session[:image_code] = nil
        session[:first_sign_in] = true
        @supplier.update_sign_in_attrs_with(request.remote_ip)

        # 初始化公众号和微官网
        # @wx_mp_user = @supplier.create_wx_mp_user!(name: current_user.nickname)
        @wx_mp_user = WxMpUser.where(supplier_id: @supplier.id).first_or_create(name: @supplier.nickname)
        @wx_mp_user.create_activity_for_website

        # @supplier.delay.init_website_data
        WebsiteInitWorker.perform_async(@supplier.id)

        return render json: {code: 0, message: "登录成功!", num: 6, status: 1}
      else
        return render json: {code: 1, message: "申请成功!", num: 6, status: 1}
      end
    else
      logger.error @supplier.errors.messages
      # return render json: {code: -2, message: "保存出错!"}
      return render json: {code: -2, message: @supplier.errors.messages.map{|k,v| "#{k}:#{v.keep_if{|v| v.present?}.join(',')}"}.join("; ") }
    end

  rescue => e
    logger.error "#{e.message}:#{e.backtrace}"
    return render json: {code: -9, message: e.message, num: 6, status: 0}
  end

  def update
    if @supplier.update_attributes(params[:supplier])
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: "更新失败，#{@supplier.errors.full_messages.join(",")}"
    end
  end

  def edit
    @partialLeftNav = "/layouts/partialLeftSys"
    render layout: 'application'
  end

  def supplier_footer
    # @ret = 1 #默认 2. 自定义 3. 不显示
    supplier_footer = SupplierFooter.find_by_id(@supplier.supplier_footer_id)
    if !@supplier.is_show_mark
      @ret = 3
    elsif supplier_footer && !supplier_footer.is_default?
      @ret = 2
    else
      @ret = 1
    end
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def update_supplier_footer
    ret = params[:status].to_i
    supplier_footer = @supplier.supplier_footer
    if ret == 1 #默认
      @supplier.supplier_footer_id = SupplierFooter.default_footer.id #使用默认 footer
      @supplier.is_show_mark = true
    elsif ret == 2
      content = params[:content]
      link = params[:link]
      supplier_footer = current_user.supplier_footers.where(is_default: false).first
      if supplier_footer && !supplier_footer.is_default? #不用新建
        supplier_footer.footer_content = content
        supplier_footer.footer_link = link
      else #要新建
        supplier_footer = SupplierFooter.create(footer_content: content, footer_link: link, supplier_id: @supplier.id)
      end
      @supplier.is_show_mark = true
      @supplier.supplier_footer_id = supplier_footer.id
    elsif ret == 3
      @supplier.is_show_mark = false
      @supplier.supplier_footer_id = supplier_footer.id if supplier_footer
    end

    if @supplier && supplier_footer && supplier_footer.save! && @supplier.save!
      redirect_to :back, notice: '更新成功'
    else
      redirect_to :back, alert: '更新失败'
    end
  end

  def send_sms
    session[:captcha], session[:mobile] = rand(100000..999999).to_s, params[:mobile].to_s
    SmsService.new.singleSend(session[:mobile], "验证码：#{session[:captcha]}")
    render json: { errcode: 0 }
  end

  def update_tel
    return redirect_to :back, alert: '更新失败，请重新获取验证码验证' if params[:supplier][:tel] != session[:mobile]
    return redirect_to :back, alert: '验证码错误' if params[:captcha] != session[:captcha]

    if @supplier.update_attributes(auth_tel: 1, tel: params[:supplier][:tel])
      redirect_to :back, notice: '验证成功'
    end
  end

  def sms_switch
    @shop_branches = current_user.shop_branches.used
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  def open_sms
    respond_to do |format|
      if @supplier.open_sms!
        format.js { render js: "$('.info').html('');$('.btn-pluin').attr('href', '#{close_sms_suppliers_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  def close_sms
    respond_to do |format|
      if @supplier.close_sms!
        format.js { render js: "$('.btn-pluin').attr('href', '#{open_sms_suppliers_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  # 发送付费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/suppliers/send_message", {phone: '13262902619', content: '电商短信测试', operation: '电商', supplier_id: 10000})
  # 发送免费短信http接口调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/suppliers/send_message", {phone: '13262902619', content: '电商短信测试', operation: '电商', supplier_id: 10000, is_free: 1})
  def send_message
    errors = []
    errors << "参数必须带有 wx_mp_user_open_id 或 supplier_id" if params[:wx_mp_user_open_id].blank? && params[:supplier_id].blank?
    errors << "参数必须带有 phone, content 和 operation" if params[:phone].blank? || params[:content].blank? || params[:operation].blank?
    errors << "短信通知功能未包含【#{params[:operation]}】模块" unless SmsExpense.operations.include?(params[:operation].to_s.strip)

    if errors.blank?
      if params[:wx_mp_user_open_id].present?
        @wx_mp_user = WxMpUser.where(uid: params[:wx_mp_user_open_id]).first
        @supplier = @wx_mp_user.try(:supplier)

      elsif params[:supplier_id].present?
        @supplier = Supplier.where(id: params[:supplier_id]).first
      end

      errors << "商户不存在" unless @supplier

      result = @supplier.send_message(params[:phone], params[:content], params[:operation], !!params[:is_free]) if @supplier
      errors = errors + result[:errors] if result.present? && result[:errors].present?
    end

    if errors.present?
      return render text: errors.join("\n")
    else
      return render text: '商户短信通知发送成功'
    end
  end

  # 发送免费短信http接口,调用方法如下：
  # RestClient.post("http://dev.winwemedia.local:3000/suppliers/send_text_message", {phone: '13262902619', content: '免费短信测试', userable_id: 10000, userable_type: 'User', source: 'winwemedia_ec', token: 'qwertyuiop[]asdfghjklzxcvbnm'})
  def send_text_message
    errors = []
    %i(phone content userable_id userable_type source token).each do |key|
    	errors << "#{key.to_s}不能为空" if params[key].blank?
    end

    errors << "token不存在" unless params[:token] == 'qwertyuiop[]asdfghjklzxcvbnm'

    if errors.blank?
      sms_service = SmsService.new
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
    def set_supplier
      @supplier = current_user
    end
end
