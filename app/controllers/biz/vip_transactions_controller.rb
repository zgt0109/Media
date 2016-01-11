class Biz::VipTransactionsController < Biz::VipController

  def index
    @account_password = current_user.account_password || current_user.build_account_password
    if session[:forget_password]
      session[:forget_password] = nil
      @notice = "你的密码是#{@account_password.password_digest}，为保证账户安全请尽快修改密码！"
    end
  end

  def create
    @account_password = current_user.build_account_password(params[:account_password])
    if @account_password.save
      return redirect_to vip_transactions_path, notice: '保存成功'
    else
      return redirect_to :back, alert: '保存失败'
    end
  end

  def update
    @account_password = current_user.account_password
    if @account_password.password_digest == params[:old_password]
      if @account_password.update_attributes(params[:account_password].merge(err_num: 0))
        return redirect_to vip_transactions_path, notice: '修改成功'
      else
        return redirect_to :back, alert: '修改失败'
      end
    else
      @account_password.err_num = @account_password.err_num + 1
      @account_password.save
      return redirect_to :back, alert: '旧密码不正确！'
    end
  end

  def check_password
    if current_user.account_password.password_digest == params[:old_password]
      status = "true"
    else
      current_user.account_password.update_column :err_num, current_user.account_password.err_num + 1
      status = "false"
    end
    render json: {status: status}
  end

  def check_protection
    if params[:email].present?
      status = current_user.account_password.email == params[:email] ? "true" : "false"
    else
      status = current_user.account_password.password_question_id == params[:password_question_id].to_i && current_user.account_password.password_answer == params[:password_answer] ? "true" : "false"
    end
    render json: {status: status}
  end

  def back_password
    render layout: "application_pop"
  end

  def forget_password
    @account_password = current_user.account_password
    render layout: "application_pop"
  end

  def sub_forget_password
    @account_password = current_user.account_password
    if params[:type] == "1"
      if @account_password.email == params[:email]
        VipUserMailer.transaction_email(@account_password).deliver
        flash[:notice] = "新的密码已发送至指定的邮箱，请登录邮箱查看！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    else
      if @account_password.password_question_id == params[:password_question_id].to_i && @account_password.password_answer == params[:password_answer]
        session[:forget_password] = "ok"
        # flash[:notice] = "你的密码是#{@account_password.password_digest}，为保证账户安全请尽快修改密码！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    end
  end

end
