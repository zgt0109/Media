# encoding: utf-8
class Payment::Yeepay < Payment::Base

  # params = {
  #   "orderid"=>"20140815221645723382_116e41753d", 
  #   "status"=>1, 
  #   "lastno"=>"6430", 
  #   "cardtype"=>2, 
  #   "merchantaccount"=>"10012411048", 
  #   "yborderid"=>411408158021260045, 
  #   "amount"=>100, 
  #   "bindvalidthru"=>1438832974, 
  #   "bankcode"=>"ICBC", 
  #   "bank"=>"工商银行"
  # }
  def paid_success!(params)
    params = HashWithIndifferentAccess.new(params)

    _attr_params = HashWithIndifferentAccess.new({
      status: 1,
      trade_status: 'TRADE_SUCCESS',
      trade_no: params[:yborderid],
      order_msg: params.to_s,
      gmt_payment: Time.now
    })

    update_attributes!(_attr_params)
  end

  # TODO
  def paid_failure!(params)
  end

  def pay_options(params)
    _amount = params[:amount] || amount
    _identityid = params[:identityid] || SecureRandom.hex(16)

    pay_params = {
      'orderid' =>  "#{out_trade_no}_#{SecureRandom.hex(5)}",# out_trade_no,
      'transtime' =>  DateTime.now.to_i,
      'currency'  =>  156,
      'amount'  =>  (_amount * 100).to_i,
      'productcatalog' =>  customer_setting.productcatalog,# 1 虚拟产品 2 信用卡还款 3 公共事业缴费 4 手机充值 5 普通商品 6 慈善和社会公益服务 7 实物商品
      "userua" => params[:userua],
      'productname' =>  "#{subject}",
      'productdesc' =>  "#{body}",
      'userip'  => params[:userip],
      'identityid' =>  _identityid,
      'identitytype' =>  0,
      'other' =>  "MAC:00-EO-4C-6C-08-75"
    }
  end

  def customer_setting
    YeepaySetting.where(status: 1, site_id: account.site.id, payment_type_id: payment_type_id).first
  end

  delegate :crypto, to: :customer_setting

  def pay_url(params)
    _params = pay_options(params)
    data = crypto.encypt_pay_credit_data(_params)

    if data.blank? or data.has_key?(:error)
      SiteLog::Payment.logger.error "yeepay encypt_data failure: #{data}"
      raise "DataEncyptFailure"
    end

    uri = crypto.yeepay_uri(YeepaySetting.api_path("pay_quest"))
    uri.query = data.to_param

    SiteLog::Payment.logger.error "*********************yeepay request uri: #{uri}"

    uri.to_s
  end

  class << self
    # 正式环境API请求基础地址
    # API_Pay_Base_Url = 'https://ok.yeepay.com/payapi/api/';
    # API_Mobile_Pay_Base_Url = 'https://ok.yeepay.com/paymobile/api/';
    # API_Merchant_Base_Url = 'https://ok.yeepay.com/merchant/';
    # https://ok.yeepay.com/payapi/mobile/pay/bankcard/debit/request
  end

end
