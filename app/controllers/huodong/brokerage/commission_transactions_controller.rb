class Huodong::Brokerage::CommissionTransactionsController < ApplicationController
  before_filter :find_broker

  def index
    @brokerage_commission_transactions = current_site.brokerage_commission_transactions.where(broker_id: params[:broker_id]).order("id DESC").page(params[:page])
  end

  def new
    @brokerage_commission_transaction = @brokerage_broker.commission_transactions.new
    render layout: 'application_pop'
  end

  def create
    @brokerage_broker.settle_commission!
    if @brokerage_broker.errors.blank?
      flash[:notice] = '操作成功'
    else
      flash[:alert] = @brokerage_broker.errors.full_messages.join('，')
    end
    render js: 'parent.location.reload();'
  end

  private

    def find_broker
      @brokerage_broker = current_site.brokerage_brokers.find(params[:broker_id])
    end
end