class Huodong::Brokerage::ClientChangesController < ApplicationController

  def index
     @client_changes = current_site.brokerage_client_changes.where(commission_transaction_id: params[:commission_transaction_id]).order("id DESC")
     render layout: 'application_pop'
  end
end
