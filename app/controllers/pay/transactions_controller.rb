class Pay::TransactionsController < Pay::BaseController

  def balance
    @records_all = current_site.payments.success.proxy_pay.order("created_at DESC").search(params[:search])
    @records = @records_all.page(params[:page])
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def index
    @records_all = @pay_account.pay_transactions.order("created_at DESC").search(params[:search])
    @records = @records_all.page(params[:page])
    respond_to do |format|
      format.html
      format.xls
    end
  end
end
