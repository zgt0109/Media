class Mobile::SmsOrdersController < Mobile::BaseController
  def alipayapi

    unless @site
      return redirect_to :back, alert: '您没有权限访问'
    end

    @sms_order = @site.sms_orders.find params[:id]

    @payment = Payment.find(params[:payment_id])

    @token = @sms_order.get_request_token(@payment)

    @data = @sms_order.auth_options(@token, @payment)

    @sign = @sms_order.generate_md5(@sms_order.sort_str(@data))

    render layout: false
  rescue => error
    WinwemediaLog::Alipay.add("alipay request faied :#{error}")
    render text: "请求失败:#{error}"
  end

  def callback
    WinwemediaLog::Alipay.add("alipay callback params:#{params}")

    if params['result'] == 'success'
      payment = Payment.where(out_trade_no: params[:out_trade_no]).first
      payment.update_attributes(trade_status: 'TRADE_SUCCESS', status: Payment::SUCCESS)
      paymentable =  payment.paymentable
      if paymentable.present?
        paymentable.update_data
        #flash[:notice] = "购买短信套餐成功"
        #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      else
        #flash[:notice] = "购买短信套餐成功"
        #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      end
    else
      #flash[:notice] = "购买短信套餐失败"
      #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    end
  end

  def notify
    WinwemediaLog::Alipay.add("alipay notify params:#{params}")

    if Payment.notify(params[:notify_data])
      render text: 'success'
    else
      render text: 'fail'
    end
  rescue => error
    WinwemediaLog::Alipay.add("alipay notify error:#{error}")
    #NotificationMailer.delay(queue: "alipayapi").job_failed("[Error] *** alipay notify error:#{error}")
    render text: 'fail'
  end

  def payment_request
    @site = Account.where(id: params[:site_id]).first
    return render json: {errcode: 001, errmsg: "site not found"} unless @site

    @payment = Payment.where(out_trade_no: params[:out_trade_no]).first
    if @payment
      return render json: {errcode: 003, errmsg: "the order has been paid"} if @payment.success?
      return render json: {errcode: 0, pay_url: @payment.get_pay_url}
    end
    @payment = Payment.setup({
      account_id: @site.account_id,
      payment_type_id: params[:payment_type_id],
      customer_id: params[:customer_id],
      customer_type: params[:customer_type],
      paymentable_id: params[:paymentable_id],
      paymentable_type: params[:paymentable_type].to_s,
      out_trade_no: params[:out_trade_no],
      amount: params[:amount],
      subject: params[:subject].to_s,
      body: params[:body].to_s,
      notify_url: params[:notify_url],
      callback_url: params[:callback_url],
      merchant_url: params[:merchant_url],
      state: params[:state],
      source: params[:source],
      open_id: params[:open_id],
      pay_params: params.to_json
    })
    tenpay_hash = { tenpay_callback: tenpay_callback_url.to_s, tenpay_notify: tenpay_notify_url.to_s, ip: request.ip}
    render json: {errcode: 0, pay_url: @payment.get_pay_url(tenpay_hash)}
  end
end
