module PaymentAlipayable
  extend ActiveSupport::Concern

  included do
    def customer_setting
      AlipaySetting.where(status: 1, site_id: site_id, payment_type_id: payment_type_id).first
    end

    delegate :alipay_send_goods_url, :alipay_url, to: :customer_setting
    attr_accessor :winwemedia_url
  end

  def pay_options(params = {})
    _amount = params[:amount] || amount
    params[:call_back_url] ||= AlipaySetting.default_params['callback_url']
    params[:notify_url] ||= AlipaySetting.default_params['notify_url']

    req_data = %(
      <direct_trade_create_req>
      <subject>支付宝支付</subject>
      <out_trade_no>#{out_trade_no}</out_trade_no>
      <total_fee>#{amount}</total_fee>
      <seller_account_name>#{customer_setting.try(:seller_email)}</seller_account_name>
      <call_back_url>#{params[:call_back_url]}</call_back_url>
      <notify_url>#{params[:notify_url]}</notify_url>
      <merchant_url>#{params[:merchant_url]}</merchant_url>
      </direct_trade_create_req>
    )

    pay_params = {
      'out_trade_no' =>  out_trade_no,# out_trade_no,
      'subject' =>  subject,
      'payment_type'  =>  1,
      'price'  =>  _amount,
      'req_data' => req_data,
      'quantity'=>  1,
      'call_back_url' => params[:call_back_url],
      'notify_url'  => params[:notify_url],
      'merchant_url'  => params[:merchant_url]
    }
  end

  def alipay_merchant_url(real_merchant_url, winwemedia_url)
    real_merchant_url ||= merchant_url
    if real_merchant_url and winwemedia_url
      winwemedia_uri = URI.parse(winwemedia_url)

      winwemedia_uri.query = {real_merchant_url: Base64.encode64(real_merchant_url)}.to_param
      "#{winwemedia_uri}"
    end
  end

  def pay_url(params = {})
    params = HashWithIndifferentAccess.new(params)

    _alipay_merchant_url = alipay_merchant_url(params.delete(:merchant_url), params.delete(:winwemedia_url))
    params[:merchant_url] = _alipay_merchant_url if _alipay_merchant_url.present?
    params.reverse_merge!(pay_options(params))

    alipay_url(params)
  end

  # params = {
  #   "payment_type"=>"1", 
  #   "subject"=>"韩国进口 延世香蕉...", 
  #   "trade_no"=>"2014073078547468", 
  #   "buyer_email"=>"gushixin@sh163.net", 
  #   "gmt_create"=>"2014-07-30 11:46:21", 
  #   "notify_type"=>"trade_status_sync", 
  #   "quantity"=>"1", 
  #   "out_trade_no"=>"14066919508857570482", 
  #   "notify_time"=>"2014-07-30 11:48:04", 
  #   "seller_id"=>"2088701973764763", 
  #   "trade_status"=>"TRADE_FINISHED", 
  #   "is_total_fee_adjust"=>"N", 
  #   "total_fee"=>"104.00", 
  #   "gmt_payment"=>"2014-07-30 11:48:04", 
  #   "seller_email"=>"wayne.weiliu@hotmail.com", 
  #   "gmt_close"=>"2014-07-30 11:48:04", 
  #   "price"=>"104.00", 
  #   "buyer_id"=>"2088002014265680", 
  #   "notify_id"=>"b67d20972931e2c25b580bdf3f4899a55s", 
  #   "use_coupon"=>"N"
  # }
  def paid_success!(params)
    params = HashWithIndifferentAccess.new(params)

    delete_attrs = params.keys - Payment.column_names
    delete_attrs.each {|attr| params.delete(attr) }

    update_attributes!( params.merge( status: 1, order_msg: params.to_s ) )
  end

  # TODO
  def paid_failure!(params)
  end

  module ClassMethods
  end
end
