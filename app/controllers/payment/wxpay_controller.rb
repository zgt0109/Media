class Payment::WxpayController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  before_filter :find_payment, :only => [:success, :fail]
  before_filter :micro_messageer_browser, :micro_messageer_browser_version,:only => [:success, :fail, :test, :pay]

  layout 'mobile/wxpay'

  #用于微信支付接口 TODO
  # 1. 判断用户微信客户端版本是否大于5.0
  # 2. 显示微信安全支付标题

  #付款后的通知会触发这个 action (post)
  def notify
    result = HashWithIndifferentAccess.new(params)[:xml]
    write_weixinv2_log "weixin v2 pay notify info -> #{result}" 
    return_code = result[:return_code]
    if return_code == "SUCCESS"
      result_code = result[:result_code]
      if result_code == "SUCCESS"
        out_trade_no = result[:out_trade_no]
        payment = Payment.where(:out_trade_no => out_trade_no).first
        if payment.success?
          return render text: notify_result("SUCCESS") 
        else
          options = {status: 1,trade_status: "TRADE_SUCCESS", buyer_id: result[:openid] , open_id: result[:openid], total_fee: result[:total_fee].to_f/100, trade_no: result[:transaction_id], order_msg: result.to_s, gmt_payment: Time.parse(result[:time_end].to_s) }     
          payment.update_pay_result options

          payment.notify_push
          #render text: 'SUCCESS'  
          return render text: notify_result("SUCCESS")   
        end  
      else
        write_weixinv2_log "weixin v2 pay notify faild -> #{result}" 
        return render text: notify_result("FAIL")   
      end  
    else
      write_weixinv2_log "weixin v2 pay notify faild -> #{result}" 
      return render text: notify_result("FAIL")   
    end  
  rescue => e
     write_weixinv2_log "weixin v2 pay notify exception -> #{e.backtrace}"
     return render text: notify_result("FAIL") 
  end

  def test
    @account = Account.where(id: params[:account_id]).first
    return render text: "请传入商户ID" unless @account

    @wxpay = @account.site.payment_settings.weixinpay.first
    return render text: "请先设置微信支付信息" unless @wxpay

    attrs = {account_id: @account.id, user_id: 10025, ec_shop_id: (@account.site.ec_shop.id rescue 2),total_amount: 0.01}
    @order = EcOrder.create(attrs)#.first_or_create

    @payment = Payment.setup({
      payment_type_id: 10001,
      account_id: @account.id,
      customer_id: @order.user_id,
      customer_type: 'User',
      paymentable_id: @order.id,
      paymentable_type: @order.class.name,
      out_trade_no: @order.order_no,
      amount: @order.total_amount,
      total_fee: @order.total_amount,
      subject: "Pay test",
      source: 'test',
      pay_params: params.to_json
    })
  end   

  # TODO 需要用网页授权获取openid
  def pay
    @account = Account.where(id: params[:account_id]).first
    return render json: {errcode: 001, errmsg: "account not found"} unless @account

    if params[:openid].present?
      @wx_user = @account.site.wx_mp_user.wx_users.where(openid: params[:openid]).first
      @wx_user = WxUser.follow(@account.site.wx_mp_user, wx_user_openid: params[:openid], wx_mp_user_openid: @account.site.wx_mp_user.try(:openid)) unless @wx_user
    else
      return render json: {errcode: 006, errmsg: "weixin user not found"}
    end

    @wxpay = @account.site.payment_settings.weixinpay.first
    return render json: {errcode: 002, errmsg: "please set weixinpay info first"} unless @wxpay

    @payment = Payment.where(out_trade_no: params[:out_trade_no]).first
    return render json: {errcode: 005, errmsg: "can't find payment"} unless @payment
    return render json: {errcode: 003, errmsg: "the order has been paid"} if @payment.success?
    
    #@payment.has_prepay_id? ? set_pay_sign_params : unifiedorder
    unifiedorder
  end

  def payfeedback
    SiteLog::Weixinpay.add("payfeedback params: #{params}")
    xml = params[:xml]
    #xml = {"OpenId"=>"obsaptzAbROOwY7pn4oZI7lXhtLc", "AppId"=>"wx7224575773890d83", "TimeStamp"=>"1395728008", "MsgType"=>"request", "FeedBackId"=>"13234327155953740587", "TransId"=>"1218314601201403218341624917", "Reason"=>"娴嬭瘯", "Solution"=>"娴嬭瘯", "ExtInfo"=>"娴嬭瘯娴嬭瘯娴嬭瘯娴嬭瘯 12052360607", "AppSignature"=>"40d5864372a50000fca64c2acc29f99efe202cd4", "SignMethod"=>"sha1"}
    #xml = {"OpenId"=>"obsapt8YtkO2Y-qe39X0-ySxm4lA", "AppId"=>"wx7224575773890d83", "TimeStamp"=>"1395729382", "MsgType"=>"reject", "FeedBackId"=>"13234327155953740587", "Reason"=>"", "AppSignature"=>"05b4a520b085a0615b39d08c6885daea2ec06bb7", "SignMethod"=>"sha1"}
    wx_user = WxUser.where(openid: xml['OpenId']).first
    mp_user = WxMpUser.where(app_id: xml['AppId']).first
    feedback = WxFeedback.where(feed_back_id: xml['FeedBackId']).first || WxFeedback.new
    msg_type = WxFeedback.msg_type_status xml['MsgType']
    if msg_type == 0
      attrs = {wx_user_id: wx_user.id, wx_mp_user_id: mp_user.id, feed_back_id: xml['FeedBackId'], msg_type:msg_type,
              trans_id: xml['TransId'], reason: xml['Reason'], solution: xml['Solution'], ext_info: xml['ExtInfo'],pic_info: xml['PicInfo']}
    else
      attrs = {wx_user_id: wx_user.id, wx_mp_user_id: mp_user.id, feed_back_id: xml['FeedBackId'], msg_type:msg_type,
               trans_id: xml['TransId'].to_s, reason: xml['Reason']}
      #attrs = {msg_type: msg_type, reason: xml['Reason']}
    end
    feedback.attributes = attrs
    if feedback.save
      render text: 'success'
    else
      render text: 'faild'
    end
  rescue => e
    SiteLog::Weixinpay.add("feedback error -> #{e.message} #{e.backtrace}")
    render :text => e
  end

  def warning
    SiteLog::Weixinpay.add("warning params: #{params}")
    render text: 'success'
  end

  def success
    @status = 1
    redirect_to payment_wxpay_fail_url(payment_id: @payment.id) unless @payment.success?
  end

  def fail
    @status = -1
    redirect_to payment_wxpay_success_url(payment_id: @payment.id) if @payment.success?
  end

  private

  def find_payment
    @payment = Payment.where(id: params[:payment_id]).first
    return render :text => "支付单不存在" unless @payment
  end

  def micro_messageer_browser
    return render text: "支付环境存在风险,请用微信内置浏览器打开" unless request.env["HTTP_USER_AGENT"].to_s.include?("MicroMessenger")
  end

  def micro_messageer_browser_version
    support_version = "5.0"
    current_version = request.user_agent.split('MicroMessenger').last.to_s.split(' ').first.to_s.gsub('/', '')
    return render text: "您的微信版本过低,无法发起支付" if current_version < support_version
  end   

  def unifiedorder
    @nonce_str = generate_noce_str
    request_options = {
      appid: @wxpay.app_id, 
      mch_id: @wxpay.partner_id, 
      nonce_str: @nonce_str, 
      body: @payment.subject, 
      out_trade_no: @payment.out_trade_no, 
      total_fee: @payment.wx_total_fee, 
      spbill_create_ip: request.remote_ip, 
      notify_url: PaymentSetting::WEIXIN_NOTICE_URL, 
      trade_type: "JSAPI", 
      openid: @wx_user.openid
    }
    sign_params = set_sign_params request_options
    xml = create_xml request_options, get_sign(sign_params, @wxpay.partner_key)
    @result = request_unifiedorder xml
    response_unifiedorder
  end

  def response_unifiedorder
    result = HashWithIndifferentAccess.new(Hash.from_xml @result)[:xml]
    return_code =  result[:return_code]
    if return_code == "SUCCESS"
      result_code = result[:result_code]
      if result_code == "SUCCESS"
        @payment.save_prepay_id result[:prepay_id]
        set_pay_sign_params
      else
        write_weixinv2_log "weixin v2 pay error payment out_trade_no : #{@payment.out_trade_no}, error: #{result}"
        return redirect_to payment_wxpay_fail_url(payment_id: @payment.id, openid: @wx_user.openid), notice: "您的订单存在异常,无法发起支付. 错误信息：#{result[:return_msg]}"
      end  
    elsif return_code == "FAIL"
      write_weixinv2_log "weixin v2 pay error payment out_trade_no : #{@payment.out_trade_no}, error: #{result}"
      return redirect_to payment_wxpay_fail_url(payment_id: @payment.id, openid: @wx_user.openid), notice: "数据异常,请尝试重试支付. 错误信息：#{result[:return_msg]}"
    else 
      write_weixinv2_log "weixin v2 pay error payment out_trade_no : #{@payment.out_trade_no}, error: #{result}"
      return render text: "data exception. 错误信息：#{result[:return_msg]}"
    end  
  end  

  def set_pay_sign_params
    @pay_sign_nonce_str = generate_noce_str
    @pay_sign_time_stamp = get_time_stamp
    pay_sign_params = ["appId=#{@wxpay.app_id}", "nonceStr=#{@pay_sign_nonce_str}", "package=prepay_id=#{@payment.prepay_id}", "signType=#{get_sign_type}", "timeStamp=#{@pay_sign_time_stamp}"]
    @pay_sign = get_sign pay_sign_params, @wxpay.partner_key
  end  

end
