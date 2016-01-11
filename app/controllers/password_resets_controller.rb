class PasswordResetsController < ActionController::Base
  def new
    render layout: "com"
  end

  def create
    if params[:email].blank? || params[:nickname].blank?
      return render json: {code: -2, message: "请同时输入邮箱和用户名", num: 1, status: 0}
    end

    account = Account.where(email: params[:email],  nickname: params[:nickname]).first
    if account.present?
      account.send_password_reset
      return render json: {code: 0, url: password_reset_path(id: account.password_reset_token), message: "登录成功!"}
   else
      if Account.where(email: params[:email]).exists?
        return render json: {code: -2, message: "用户名不正确", num: 0, status: 0}
      elsif   Account.where(nickname: params[:nickname]).exists?
        return render json: {code: -2, message: "邮箱不正确", num: 1, status: 0}
      else
        return render json: {code: -2, message: "未找到对应用户", num: 0, status: 0}
      end
   end
  end

  def resend_email
    @account = Account.find_by_password_reset_token(params[:id])
    @account.send_password_reset
    render nothing: true
  end

  def show
    @account = Account.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @account
    render layout: "com"
  end

  def edit
    @account = Account.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @account
    @expired = (@account.password_reset_sent_at < 30.minutes.ago)
    render layout: "com"
  end

  def update
    @account = Account.find_by_password_reset_token(params[:id])
    return redirect_to root_url unless @account

    if @account.password_reset_sent_at < 30.minutes.ago
      return render json: {code: -2, message: "重置邮件已失效"}
    elsif @account.update_attributes(params[:account])
      @account.update_sign_in_attrs_with(request.remote_ip)
      AccountLog.logging(@account, request)

      session[:account_id] = @account.id
      session[:image_code] = nil

      return render json: {code: 0, url: root_url}
    else
      puts @account.errors.inspect
      render json: {code: -2, message: @account.errors.full_messages.last}
    end
  end

end
