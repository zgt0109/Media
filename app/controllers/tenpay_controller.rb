class TenpayController < ApplicationController

  skip_before_filter *ADMIN_FILTERS

  # 财付通回调 验证签名
  def callback
    logger.info "----------- call back ====== #{params}------------------"
    @payment = Payment.where(:out_trade_no => params[:out_trade_no]).first
    @tenpay  = @payment.supplier.payment_settings.tenpay.first
    # notify may reach earlier than callback
    if JaslTenpay::Sign.verify?(params.except(*request.path_parameters.keys), @tenpay.partner_id, @tenpay.partner_key)
      params[:status] = "1"
      callback_uri = URI(@payment.callback_url)
      callback_uri.query = params.to_param
      return redirect_to callback_uri.to_s
    else
      params[:status] = "-1"
      callback_uri = URI(@payment.callback_url)
      callback_uri.query = params.to_param
      return redirect_to callback_uri.to_s
    end
  end

  # 通知接口, 接到通知后先自己更新数据库, 然后要记得反还给微电商
  # {
  #   "bank_billno"=>"201405220907772", 
  #   "bank_type"=>"CCB", 
  #   "discount"=>"0", 
  #   "fee_type"=>"1", 
  #   "input_charset"=>"UTF-8", 
  #   "notify_id"=>"JMRX0uy_b41M2Arnquv4SugxId0BbEjIzoz9uiayhc_yRmmjy1R-5rmLjNtM_tQPFhD-0mH_Ybht7aNGuuOccpQRsftCD3JU", 
  #   "out_trade_no"=>"140074402511220_2aff1bf9be", 
  #   "partner"=>"1218729701", 
  #   "product_fee"=>"56", 
  #   "sign_type"=>"MD5", 
  #   "time_end"=>"20140522182045", 
  #   "total_fee"=>"56", 
  #   "trade_mode"=>"1", 
  #   "trade_state"=>"0", 
  #   "transaction_id"=>"1218729701201405220606864983", 
  #   "transport_fee"=>"0", 
  #   "sign"=>"1F30C07C9A97F5E1B59E1C20819C91D3", 
  # }
  def notify
    logger.info "----------- notify back #{params}------------------"
    payment = Payment.where(:out_trade_no => params[:out_trade_no]).first
    tenpay  = payment.supplier.payment_settings.tenpay.first
    if JaslTenpay::Notify.verify?(params.except(*request.path_parameters.keys), tenpay.partner_id, tenpay.partner_key)
      return render :text => 'success' if payment.status == Payment::SUCCESS

      payment.status = 1
      payment.trade_status = 'TRADE_SUCCESS'
      payment.trade_no = params[:transaction_id]
      payment.total_fee = params[:total_fee].to_f/100
      payment.discount = params[:discount].to_f/100
      payment.gmt_payment = Time.parse(params[:time_end])
      payment.notify_id = params[:notify_id]
      payment.sign_type = params[:sign_type]
      payment.order_msg = params.to_s
      payment.save!

      payment.notify_push
      # WinwemediaLog::Weixinpay.add("请求失败:#{e.message}\n#{e.backtrace}")
      return render text: 'success'
    else
      params["status"] = "-1"
      msg = RestClient.post(payment.notify_url, params)
      return render text: 'fail'
    end
  end

end
