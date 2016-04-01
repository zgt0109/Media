class Pay::AccountsController < Pay::BaseController
  def create
    return redirect_to identity_pay_accounts_path if @pay_account.present?
    @pay_account = PayAccount.new(params[:pay_account])
    @pay_account.status = -3
    @pay_account.account_id = current_user.id
    if @pay_account.save
      redirect_to identity_pay_accounts_path
    else
      render_with_alert :apply, "保存失败: #{@pay_account.errors.full_messages.join('，')}"
    end
  end

  def index
    if @pay_account.blank? || @pay_account.progressing?
      redirect_to apply_pay_accounts_path
    end
  end

  def update
    unless (@pay_account.progressing? || @pay_account.denied?)
      return redirect_to pay_accounts_path, alert: "保存失败"
    end
    @pay_account.attributes = params[:pay_account]

    if @pay_account.save
      if params[:pay_account][:step3].present?
        @pay_account.update_attributes(status: 0)
        redirect_to pay_accounts_path
      elsif params[:pay_account][:step2].present?
        redirect_to account_pay_accounts_path
      else
        redirect_to identity_pay_accounts_path
      end
    else
      if params[:pay_account][:step3].present?
        return_action = :account
      elsif params[:pay_account][:step2].present?
        return_action = :identity
      else
        return_action = :index
      end
      render_with_alert return_action,  "保存失败: #{@pay_account.errors.full_messages.join('，')}"
    end
  end

  private
    def fetch_pay_account
      @pay_account = current_user.pay_account
    end

end
