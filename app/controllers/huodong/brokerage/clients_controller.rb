class Huodong::Brokerage::ClientsController < Huodong::Brokerage::BaseController
	before_filter :find_brokerage_client, only: [:edit, :update]
	before_filter :find_commission_types
	before_filter :find_commission_types_enable

	def index
		@total_brokerage_clients = current_user.brokerage_clients
		@search = @total_brokerage_clients.search(params[:search])
		@brokerage_clients = @search.order('id DESC').page(params[:page])
	end

	def edit
		render layout: 'application_pop'
	end


	def update
		if @brokerage_client.change_commission_type(params[:brokerage_client][:commission_type_id], BigDecimal.new(params[:brokerage_client][:change_commission]))
			flash[:notice] = '操作成功'
		else
			flash[:alert] = @brokerage_client.errors.full_messages.join('，')
		end
	rescue => e
			flash[:alert] = e.message
	ensure
		render js: 'parent.location.reload();'
 end

	private
		def find_brokerage_client
			@brokerage_client = current_user.brokerage_clients.find(params[:id])
		end

		def find_commission_types
			@commission_types = current_user.brokerage_commission_types.map(&:mission_type_name_with_id)
		end

		def find_commission_types_enable
			@commission_types_enable = current_user.brokerage_commission_types.enabled.map(&:mission_type_name_with_id)
		end

end
