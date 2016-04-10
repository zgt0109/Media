# render text: 'success'
# 微信后台通过 notify_url 通知商户，商户做业务处理后，需要以字符串的形式反馈处理结果，内容如下：
# success 处理成功，微信系统收到此结果后丌再迚行后续通知
# fail 戒其它字符 处理丌成功，微信收到此结果戒者没有收到仸何结果，系统通过补单机制再次通知

class WxpayController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  before_filter :find_payment, :only => [:success, :fail]

  layout 'mobile/wxpay'

  #用于微信支付接口 TODO
  # 1. 判断用户微信客户端版本是否大于5.0
  # 2. 显示微信安全支付标题

  #付款后的通知会触发这个 action (post)
  def notify
    CustomLog::Weixinpay.add("notfiy params: #{params}")
    # params =  {
    #   "xml"=>{
    #     "OpenId"=>"obsapt8YtkO2Y-qe39X0-ySxm4lA", 
    #     "AppId"=>"wx7224575773890d83", 
    #     "IsSubscribe"=>"1", 
    #     "TimeStamp"=>"1394679393", 
    #     "NonceStr"=>"pyiUUXcMey4B3tZZ", 
    #     "AppSignature"=>"6516f4034a697fd85fbfe58a4f105cf984e5378a", 
    #     "SignMethod"=>"sha1"
    #   }, 
    #   "bank_billno"=>"201403137066024", 
    #   "bank_type"=>"0", 
    #   "discount"=>"0", 
    #   "fee_type"=>"1", 
    #   "input_charset"=>"GBK", 
    #   "notify_id"=>"2Y9Ozj19yUXpb5Om3PTx23NU_ctGVMla8GC_B6MJtSMqdkHBL0r7US__cVdOWkpW1eq7AYMcamEVFBkte6qhyRsTAcMA8mOt", 
    #   "out_trade_no"=>"20140325163052947525", 
    #   "partner"=>"1218314601", 
    #   "product_fee"=>"1", 
    #   "sign_type"=>"MD5", 
    #   "time_end"=>"20140313105617", 
    #   "total_fee"=>"1", 
    #   "trade_mode"=>"1", 
    #   "trade_state"=>"0", 
    #   "transaction_id"=>"1218314601201403138306604513", 
    #   "transport_fee"=>"0", 
    #   "sign"=>"078CB574F7382E019D18621F693651A6"
    # }
    payment = Payment.where(:out_trade_no => params[:out_trade_no]).first

    if payment.success?
      render :text => 'success'
    elsif params[:trade_state].to_s == "0"
      Payment.transaction do
        payment.status = 1
        payment.trade_status = 'TRADE_SUCCESS'
        payment.trade_no = params[:transaction_id]
        payment.total_fee = params[:total_fee].to_f/100
        payment.discount = params[:discount].to_f/100
        payment.gmt_payment = Time.parse(params[:time_end])
        payment.notify_id = params[:notify_id]
        payment.sign_type = params[:sign_type]
        payment.order_msg = params.to_s
        payment.buyer_id = params['xml']['OpenId']
        payment.open_id = params['xml']['OpenId']
        payment.save!
      end

      yaic_payment(payment) if payment.paymentable_type == "YonganOrder"

      payment.notify_push

      render text: 'success'
    else
      render text: 'fail'
    end
  rescue => e
    CustomLog::Weixinpay.add("weixin test pay error -> #{e.backtrace}")
    render text: 'fail'
  end

  def index
    @account = Account.where(id: params[:account_id]).first
    return render text: "请传入商户ID" unless @account

    @wxpay = @account.payment_settings.wxpay.first
    return render text: "请先设置微信支付信息" unless @wxpay

    attrs = {account_id: @account.id, user_id: 10025, ec_shop_id: (@account.ec_shop.id rescue 2),total_amount: 0.01}
    @order = EcOrder.create(attrs)#.first_or_create

    payment = Payment.setup({
      payment_type_id: 10001,
      account_id: @account.id,
      customer_id: @order.user_id,
      customer_type: 'User',
      paymentable_id: @order.id,
      paymentable_type: @order.class.name,
      out_trade_no: @order.order_no,
      amount: @order.total_amount,
      subject: "微信支付测试",
      source: 'test',
      pay_params: params.to_json
    })
  end

  def pay
    @account = Account.where(id: params[:account_id]).first
    return render json: {errcode: 001, errmsg: "account not found"} unless @account

    @wxpay = @account.payment_settings.wxpay.first
    return render json: {errcode: 002, errmsg: "please set wxpay info first"} unless @wxpay

    @payment = Payment.where(out_trade_no: params[:out_trade_no]).first
    return render json: {errcode: 005, errmsg: "can't find payment"} unless @payment
    return render json: {errcode: 003, errmsg: "the order has been paid"} if @payment.success?
  end

  def payfeedback
    CustomLog::Weixinpay.add("payfeedback params: #{params}")
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
    CustomLog::Weixinpay.add("feedback error -> #{e.message} #{e.backtrace}")
    render :text => e
  end

  def warning
    CustomLog::Weixinpay.add("warning params: #{params}")
    render text: 'success'
  end

  def success
    @status = 1
    redirect_to wxpay_fail_url(payment_id: @payment.id) unless @payment.success?
  end

  def fail
    @status = -1
    redirect_to wxpay_success_url(payment_id: @payment.id) if @payment.success?
  end

  private

  def find_payment
    @payment = Payment.where(id: params[:payment_id]).first
    render :text => "支付单不存在" unless @payment
  end
end
