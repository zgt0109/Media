class Biz::VipTransactionsController < Biz::VipController

  def index
    @supplier_password = current_user.supplier_password || current_user.build_supplier_password
    if session[:forget_password]
      session[:forget_password] = nil
      @notice = "你的密码是#{@supplier_password.password_digest}，为保证账户安全请尽快修改密码！"
    end
  end

  def create
    @supplier_password = current_user.build_supplier_password(params[:supplier_password])
    if @supplier_password.save
      return redirect_to vip_transactions_path, notice: '保存成功'
    else
      return redirect_to :back, alert: '保存失败'
    end
  end

  def update
    @supplier_password = current_user.supplier_password
    if @supplier_password.password_digest == params[:old_password]
      if @supplier_password.update_attributes(params[:supplier_password].merge(err_num: 0))
        return redirect_to vip_transactions_path, notice: '修改成功'
      else
        return redirect_to :back, alert: '修改失败'
      end
    else
      @supplier_password.err_num = @supplier_password.err_num + 1
      @supplier_password.save
      return redirect_to :back, alert: '旧密码不正确！'
    end
  end

  def check_password
    if current_user.supplier_password.password_digest == params[:old_password]
      status = "true"
    else
      current_user.supplier_password.update_column :err_num, current_user.supplier_password.err_num + 1
      status = "false"
    end
    render json: {status: status}
  end

  def check_protection
    if params[:email].present?
      status = current_user.supplier_password.email == params[:email] ? "true" : "false"
    else
      status = current_user.supplier_password.password_question_id == params[:password_question_id].to_i && current_user.supplier_password.password_answer == params[:password_answer] ? "true" : "false"
    end
    render json: {status: status}
  end

  def back_password
    render layout: "application_pop"
  end

  def forget_password
    @supplier_password = current_user.supplier_password
    render layout: "application_pop"
  end

  def sub_forget_password
    @supplier_password = current_user.supplier_password
    if params[:type] == "1"
      if @supplier_password.email == params[:email]
        VipUserMailer.transaction_email(@supplier_password).deliver
        flash[:notice] = "新的密码已发送至指定的邮箱，请登录邮箱查看！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    else
      if @supplier_password.password_question_id == params[:password_question_id].to_i && @supplier_password.password_answer == params[:password_answer]
        session[:forget_password] = "ok"
        # flash[:notice] = "你的密码是#{@supplier_password.password_digest}，为保证账户安全请尽快修改密码！"
        render inline: '<script>parent.document.location = parent.document.location;</script>';
      else
        render_with_alert :forget_password, "找回失败", layout: 'application_pop'
      end
    end
  end

end
