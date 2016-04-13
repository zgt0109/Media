class Mobile::DonationOrdersController < Mobile::BaseController
  layout false

  def new
    @donation_order = DonationOrder.find(params[:id])
  end

  def create
    @donation_order = DonationOrder.new(params[:donation_order])
    if @donation_order.save
      redirect_to new_mobile_donation_order_url(site_id: session[:site_id],id: @donation_order.id)
    end
  end

  def pay
    @donation_order = DonationOrder.find(params[:id])

    if @donation_order.update_attributes(params[:donation_order]) && @donation_order.pending?
      options = {
        callback_url: callback_payments_url,
        notify_url: notify_payments_url,
        merchant_url: my_orders_mobile_donations_url(site_id: session[:site_id])
      }
      @payment_request_params = @donation_order.payment_request_params(options)

      # render "app/vips/pay"
    else
      redirect_to my_orders_mobile_donations_url(site_id: paymentable.site_id)
    end
  end

  def update
    @donation_order = DonationOrder.find(params[:id])

    # 跳到财付通的界面
    if @donation_order.update_attributes(params[:donation_order])
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
    logger.info "----------- into mobile call back #{params}------------------"
    @donation_order = DonationOrder.find(params[:order_id])
    @donation_order.update_column("state", 2)
    # notify may reach earlier than callback, 捐款是定制功能, 所以 id 和 key 写死
    if JaslTenpay::Sign.verify?(params.except(*request.path_parameters.keys), '1218296701', '159e64f1c16a0dcf50f63731d7c07cde') 
      logger.info "sign ok ....................."     
      logger.info "the @donation_order is  #{@donation_order.inspect} ......"
      @donation_order.update_attributes :transaction_id => params[:transaction_id],
                               :trade_state => params[:trade_state],
                               :pay_info => params[:pay_info],
                               :paid_at => params[:time_end],
                               :state => 2

      logger.info "the @donation_order after update is  #{@donation_order.inspect} ......"                                 
    end
    # 发送feedback给捐款人
    mp_user = @donation_order.donation.site.wx_mp_user
    content = @donation_order.donation.feedback
    unless content.blank?
      mp_user.auth!
      json = "{\"touser\":\"#{@wx_user.openid}\",\"msgtype\":\"text\",\"text\": { \"content\":\"#{content}\" }}"
      result = RestClient.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}", json, :content_type => :json, :accept => :json)
      logger.info "===============================#{result}================="
      if result =~ /"errcode":40001/
        mp_user.auth!
        result = RestClient.post("https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=#{mp_user.access_token}", json, :content_type => :json, :accept => :json)
      end
    end
    redirect_to success_mobile_donation_orders_url(site_id: session[:site_id], aid: @donation_order.donation.activity.id), notice: '捐款已成功'
  end

  def success
    logger.info "------- success ----#{params}-------"
    @user = User.find(session[:user_id])
    @activity = Activity.find(params[:aid])
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
    respond_to do |format|
      format.xls
    end
  end

  private

  def generate_tenpay_url(options)
    options = {
      :return_url => callback_mobile_donation_orders_url(site_id: session[:site_id], order_id: options[:order_id]),
      :notify_url => notify_mobile_donation_orders_url(site_id: session[:site_id], order_id: options[:order_id]),
      :spbill_create_ip => request.ip,
    }.merge(options)
    JaslTenpay::Service.create_interactive_mode_url(options, '1218296701', '159e64f1c16a0dcf50f63731d7c07cde')
  end

end
