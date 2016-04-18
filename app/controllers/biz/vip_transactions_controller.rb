class Biz::VipTransactionsController < Biz::VipController

  def index
    @user_password = current_site.user_password || current_site.build_user_password
    if session[:forget_password]
      session[:forget_password] = nil
      @notice = "你的密码是#{@user_password.password_digest}，为保证账户安全请尽快修改密码！"
    end
  end

  def create
    @user_password = current_site.build_user_password(params[:user_password])
    if @user_password.save
      return redirect_to vip_transactions_path, notice: '保存成功'
    else
      return redirect_to :back, alert: '保存失败'
    end
  end

  def update
    @user_password = current_site.user_password
    if @user_password.password_digest == params[:old_password]
      if @user_password.update_attributes(params[:user_password].merge(err_num: 0))
        return redirect_to vip_transactions_path, notice: '修改成功'
      else
        return redirect_to :back, alert: '修改失败'
      end
    else
      @user_password.err_num = @user_password.err_num + 1
      @user_password.save
      return redirect_to :back, alert: '旧密码不正确！'
    end
  end

  def check_password
    if current_site.user_password.password_digest == params[:old_password]
      status = "true"
    else
      current_site.user_password.update_column :err_num, current_site.user_password.err_num + 1
      status = "false"
    end
    render json: {status: status}
  end

  def check_protection
    if params[:email].present?
      status = current_site.user_password.email == params[:email] ? "true" : "false"
    else
      status = current_site.user_password.password_question_id == params[:password_question_id].to_i && current_site.user_password.password_answer == params[:password_answer] ? "true" : "false"
    end
    render json: {status: status}
  end

  def back_password
    render layout: "application_pop"
  end

  def forget_password
    @user_password = current_site.user_password
    render layout: "application_pop"
  end

  def sub_forget_password
    @user_password = current_site.user_password
    if params[:type] == "1"
      if @user_password.email == params[:email]
        VipUserMailer.transaction_email(@user_password).deliver
        flash[:notice] = "新的密码已发送至指定的邮箱，请登录邮箱查看！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    else
      if @user_password.password_question_id == params[:password_question_id].to_i && @user_password.password_answer == params[:password_answer]
        session[:forget_password] = "ok"
        # flash[:notice] = "你的密码是#{@user_password.password_digest}，为保证账户安全请尽快修改密码！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    end
  end

end
