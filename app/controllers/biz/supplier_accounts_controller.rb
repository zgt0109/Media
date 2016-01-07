class Biz::SupplierAccountsController < Biz::winwemediaPayController
	def create
		return redirect_to identity_supplier_accounts_path if @supplier_account.present?
		@supplier_account = SupplierAccount.new(params[:supplier_account])
		@supplier_account.status = -3
		if @supplier_account.save
			redirect_to identity_supplier_accounts_path
		else
			render_with_alert :apply, "保存失败: #{@supplier_account.errors.full_messages.join('，')}"
		end
	end

	def index
		if @supplier_account.blank? || @supplier_account.progressing?
			redirect_to apply_supplier_accounts_path
		end
	end

	def apply

	end

	#申请人信息
	def identity

	end

	#账户信息
	def account

	end

	#账户信息
	def conditions

	end

	def update
		unless (@supplier_account.progressing? || @supplier_account.denied?)
			return redirect_to supplier_accounts_path, alert: "保存失败"
		end
		@supplier_account.attributes = params[:supplier_account]

		if @supplier_account.save
			if params[:supplier_account][:step3].present?
				@supplier_account.update_attributes(status: 0)
				redirect_to supplier_accounts_path
			elsif params[:supplier_account][:step2].present?
				redirect_to account_supplier_accounts_path
			else
				redirect_to identity_supplier_accounts_path
			end
		else
			if params[:supplier_account][:step3].present?
				return_action = :account
			elsif params[:supplier_account][:step2].present?
				return_action = :identity
			else
				return_action = :index
			end
			render_with_alert return_action,  "保存失败: #{@supplier_account.errors.full_messages.join('，')}"
		end
	end

	def balance

	end

	private
	def fetch_supplier_account
		@supplier_account = current_user.supplier_account
	end

end
