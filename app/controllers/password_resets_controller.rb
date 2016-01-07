class PasswordResetsController < ActionController::Base
  def new
    render layout: "com"
  end

  def create
    if params[:email].blank? || params[:nickname].blank?
      return render json: {code: -2, message: "请同时输入邮箱和用户名", num: 1, status: 0}
    end

    # if params[:verify_code].present?
    #   if session[:image_code] and session[:image_code] != params[:verify_code]
    #      return render json: {code: -2, message: "验证码错误"}
    #   end
    # else
    #     return render json: {code: -2, message: "请输入验证码"}
    # end

    supplier = Supplier.where(email: params[:email],  nickname: params[:nickname]).first
    if supplier.present?
      supplier.send_password_reset
      return render json: {code: 0, url: password_reset_path(id: supplier.password_reset_token), message: "登录成功!"}
   else
      if Supplier.where(email: params[:email]).exists?
        return render json: {code: -2, message: "用户名不正确", num: 0, status: 0}
      elsif   Supplier.where(nickname: params[:nickname]).exists?
        return render json: {code: -2, message: "邮箱不正确", num: 1, status: 0}
      else
        return render json: {code: -2, message: "未找到对应用户", num: 0, status: 0}
      end
   end
  end

  def resend_email
    @supplier = Supplier.find_by_password_reset_token(params[:id])
    @supplier.send_password_reset
    render nothing: true
  end

  def show
    @supplier = Supplier.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @supplier
    render layout: "com"
  end

  def edit
    @supplier = Supplier.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @supplier
    @expired = (@supplier.password_reset_sent_at < 30.minutes.ago)
    render layout: "com"
  end

  def update
    @supplier = Supplier.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @supplier
    if @supplier.password_reset_sent_at < 30.minutes.ago
      return render json: {code: -2, message: "重置邮件已失效"}
    elsif @supplier.update_attributes(params[:supplier])

      @supplier.update_sign_in_attrs_with(request.remote_ip)
      AccountLog.logging(@supplier, request)

      session[:pc_supplier_id] = @supplier.id
      session[:image_code] = nil
      session[:agent_name] = params[:agent_name] if params[:agent_name]

      if @supplier.try(:wx_mp_user).try(:active?)
        url = root_url
      else
        url = platforms_url
      end
      return render json: {code: 0, url: url}
    else
      puts @supplier.errors.inspect
      render json: {code: -2, message: @supplier.errors.full_messages.last}
    end
  end

end
