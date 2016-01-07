# encoding: utf-8
module YeepayLib::Interface
  extend ActiveSupport::Concern

  included do
  end

  def pay_options(params = nil)
    params ||= {}
    # merchantaccount
    default_opions = default_params.reverse_merge(
      'orderid' =>  generate_order_no,
      'transtime' =>  DateTime.now.to_i,
      'currency'  =>  156,
      'amount'  =>  2,
      'productcatalog'=>  "1",# 1 虚拟产品 2 信用卡还款 3 公共事业缴费 4 手机充值 5 普通商品 6 慈善和社会公益服务 7 实物商品
      "userua" => "你好",
      'productname' =>  "小薇",
      'productdesc' =>  "成品 3 级小薇一个",
      'userip'  =>  "192.168.5.251",
      'identityid'  =>  'ee',
      'identitytype'  =>  0,
      'other'     =>  "MAC:00-EO-4C-6C-08-75",
    )

    HashWithIndifferentAccess.new(params).reverse_merge!(default_opions)
  end

  def encypt_pay_credit_data(params = nil)
    _params = pay_options(params)
    encypted_result = encypt_data(_params)
  end

  def encypt_query_order_credit_data(params = {orderid: nil})
    params.reverse_merge({merchantaccount: merchantaccount})

    HashWithIndifferentAccess.new encypt_data(params)
  end

  def query_order(url = nil, params = {orderid: nil})
    params = HashWithIndifferentAccess.new params
    url ||= '/testpayapi/api/query/order'
    _params = encypt_query_order_credit_data(params)

    uri = yeepay_uri(url)
    # uri.read
    launch_request(uri, _params)
  end

  def bind_pay_async(url = nil, params = {})
    uri = yeepay_uri('/testpayapi/api/bankcard/bind/pay/async')

    _default_options = default_params.reverse_merge({
                         bindid: '940',
                         orderid: generate_order_no,
                         transtime: DateTime.now.to_i,
                         currency: 156,
                         amount: 2,
                         productcatalog: "1",
                         productname: "小薇",
                         productdesc: "成品 3 级小薇一个",
                         userip: "192.168.5.251",
                         identityid: "ee",
                         identitytype: 6,
                         other: "MAC:00-EO-4C-6C-08-75"
                       })
    _params =  HashWithIndifferentAccess.new(params).reverse_merge!(_default_options)

    launch_request(uri, _params)
  end
end
