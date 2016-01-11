class Huodong::Brokerage::BrokersController < Huodong::Brokerage::BaseController

	def index
		@total_brokerage_brokers = current_site.brokerage_brokers
		@search = @total_brokerage_brokers.search(params[:search])
		@brokerage_brokers = @search.order("id DESC").page(params[:page])
	end

	def show
		@brokerage_broker = current_site.brokerage_brokers.find(params[:id])
		render layout: 'application_pop'
	end

end