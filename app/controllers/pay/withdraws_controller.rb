class Pay::WithdrawsController < Pay::BaseController

  def index
    @records_all = @pay_account.pay_withdraws.order("created_at DESC").search(params[:search])
    @records = @records_all.page(params[:page])
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def service_recharge
    resquest_amount = params[:resquest_amount].to_f
    fee = PayWithdraw.fee(resquest_amount)
    withdrawed_amount = resquest_amount - fee
    render json: {fee: fee, withdrawed_amount: withdrawed_amount}
  end

  def request_withdraw
    render layout: 'application_pop'
  end

  def confirm_withdraw
    resquest_amount = params[:resquest_amount].to_f
    if resquest_amount.present? && resquest_amount <= @pay_account.balance && resquest_amount >= 1000.00
      @pay_account.update_attributes(balance: @pay_account.balance - resquest_amount, froze_amount: @pay_account.froze_amount + resquest_amount)
      fee = PayWithdraw.fee(resquest_amount)
      receive_amount = resquest_amount - fee
      @pay_account.pay_withdraws.create(amount: resquest_amount, fee: fee, receive_amount: receive_amount)
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :request_withdraw, "提现金额必须是大于等于1000,小于等于可提现金额的数字"
    end
  end

end
