class SupplierWithdraw < ActiveRecord::Base
	belongs_to :supplier
	belongs_to :supplier_account
	before_create :generate_running_number
	before_create :generate_default_attributes

	enum_attr :status, :in => [
		['pending',  0, '待处理'],
		['success',    1, '提现成功'],
		['failure',   -1, '提现失败']
	]

	def self.fee(amount)
		service_charge = if amount < 10000
			 5.00
		elsif amount < 100000
			10.00
		elsif amount < 500000
			15.00
		elsif amount < 1000000
			20.00
		elsif amount >= 1000000
			amount * 0.00002
		else
			0.00
		end
		service_charge = 200.00 if service_charge > 200.00
		service_charge.to_f.round(2)
	end

	private
	def generate_default_attributes
		self.supplier_id = supplier_account.supplier_id
		self.bank_name = supplier_account.bank_name
		self.bank_branch = supplier_account.bank_branch
		self.bank_name = supplier_account.bank_name
		self.bank_account = supplier_account.bank_account
	end

	def generate_running_number
		self.running_number = Time.now.to_formatted_s(:number).to_s  + SecureRandom.hex.first(3)
	end

end
