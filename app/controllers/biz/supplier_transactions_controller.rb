class Biz::SupplierTransactionsController < Biz::WinwemediaPayController

	def balance
		@records_all = current_user.payments.success.winwemedia_pay.order("created_at DESC").search(params[:search])
		@records = @records_all.page(params[:page])
		respond_to do |format|
			format.html
			format.xls
		end
	end

	def index
		@records_all = @supplier_account.supplier_transactions.order("created_at DESC").search(params[:search])
		@records = @records_all.page(params[:page])
		respond_to do |format|
			format.html
			format.xls
		end
	end

end
