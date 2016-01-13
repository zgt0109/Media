module App
  class DonationOrdersController < BaseController

    layout false

    def new
      @temp = params[:temp]
      @donation_order = DonationOrder.new(user_id: session[:user_id], :site_id => @site.try(:id))
    end

    def create
      @donation_order = DonationOrder.new(params[:donation_order])
      if @donation_order.save
        url = generate_tenpay_url :order_id => @donation_order.id,
                                  :subject => "捐款",
                                  :body => "我要捐款",
                                  :total_fee => (@donation_order.fee * 100).to_i,
                                  :out_trade_no => @donation_order.trade_no
        return redirect_to url
      end
    end

 

    # 财付通回调 验证签名 
    def callback
      logger.info "----------- call back #{params}------------------"
      # notify may reach earlier than callback, 捐款是定制功能, 所以 id 和 key 写死
      if JaslTenpay::Sign.verify?(params.except(*request.path_parameters.keys), '1218296701', '159e64f1c16a0dcf50f63731d7c07cde') 
        @donation_order = DonationOrder.find(params[:order_id])
        @donation_order.update_attributes :transaction_id => params[:transaction_id],
                                 :trade_state => params[:trade_state],
                                 :pay_info => params[:pay_info],
                                 :paid_at => params[:time_end],
                                 :state => 2
      end
      redirect_to new_app_donation_order_url, notice: '捐款已成功'
    end

    # 通知接口
    def notify
      logger.info "----------- notify back #{params}------------------"
      #捐款是定制功能, 所以 id 和 key 写死
      if JaslTenpay::Notify.verify?(params.except(*request.path_parameters.keys), '1218296701', '159e64f1c16a0dcf50f63731d7c07cde')
        @donation_order = DonationOrder.find(params[:order_id])
        @donation_order.update_attributes :transaction_id => params[:transaction_id],
                                 :trade_state => params[:trade_state],
                                 :pay_info => params[:pay_info],
                                 :paid_at => params[:time_end],
                                 :state => 3
        render text: 'success'
      else
        render text: 'fail'
      end
    end

    def print
      puts "----- print ========="
      respond_to do |format|
        format.xls
      end
    end

  private
    def generate_tenpay_url(options)
      options = {
          :return_url => callback_app_donation_orders_url(order_id: options[:order_id]),
          :notify_url => notify_app_donation_orders_url(order_id: options[:order_id]),
          :spbill_create_ip => request.ip,
      }.merge(options)
      JaslTenpay::Service.create_interactive_mode_url(options, '1218296701', '159e64f1c16a0dcf50f63731d7c07cde')
    end
  end
end
