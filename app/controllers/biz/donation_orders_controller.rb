class Biz::DonationOrdersController < ApplicationController

	def pay
		@donation_order = DonationOrder.find(params[:id])
		@donation_order.confirmed!
		return redirect_to :back, notice: "操作成功"
	end

	def unpay
		@donation_order = DonationOrder.find(params[:id])
		@donation_order.cancel!
		return redirect_to :back, notice: "操作成功"
	end

end