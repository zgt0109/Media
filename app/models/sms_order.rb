class SmsOrder < ActiveRecord::Base
  belongs_to :account
  belongs_to :site
  has_many   :payments, as: :paymentable

  attr_accessor :payment_type

  PLANS = {
    1 => {plan_name: 'A套餐-100元/1000条', plan_type: 1, plan_sms: 1000, plan_cost: 10000},
    2 => {plan_name: 'B套餐-400元/5000条', plan_type: 1, plan_sms: 5000, plan_cost: 40000},
    3 => {plan_name: 'C套餐-1000元/15000条', plan_type: 1, plan_sms: 15000, plan_cost: 100000},
    4 => {plan_name: 'V-领先专业版（赠送）', plan_type: 2, plan_sms: 100, plan_cost: 0},
    5 => {plan_name: 'V-行业解决方案（赠送）', plan_type: 2, plan_sms: 500, plan_cost: 0},
  }

  ALIPAY_ACCOUNT_NAME = "payment@winwemedia.com"
  ALIPAY_ID = "2088121855721480"
  ALIPAY_KEY = "2xfcmsfv5cxkehizxiuycsqpuzghd0j8"

  enum_attr :plan_type, :in => [
    ['buy', 1, '购买'],
    ['giv', 2, '赠送'],
  ]

  enum_attr :payment_type, :in => [
    #['wxpay',  10001, '微信支付'],
    #['yeepay', 10002, '易宝支付'],
    ['alipay', 10003, '支付宝支付'],
    #['tenpay', 10004, '财付通支付'],
  ]

  enum_attr :status, :in => [
    ['pending', 0, '待支付'],
    ['succeed', 1, '已支付'],
    ['cancel', 3, '已取消'],
    ['failure', 2, '支付失败'],
    ['f_delete', 4, '假删除'],
    ['t_delete', 5, '真删除'],
  ]

  before_create :add_default_attrs

  class << self

    def plan_id_options
      arr = []
      PLANS.each{|key, value| arr << [value[:plan_name], key]}
      arr
    end

    def usable_buy
      arr = []
      PLANS.each{|key, value| arr << [key, value] if value[:plan_type] == SmsOrder::BUY}
      arr
    end

     # 每月1日凌晨重置赠送短信套餐
     def reset_free_sms_every_month(options = {})
      options[:clear_free_sms_orders] ||= false
      if options[:clear_free_sms_orders]
        # 清空历史赠送套餐数据
        Account.update_all "free_sms = 0"
        SmsOrder.delete_all(plan_type: 2)
      end

      # 行业解决方案商户 每月赠送500条短信
      plan_id = 5
      industries_ids = AccountIndustry.where("name like '%行业解决方案%'").map{|si| si.id}
      accounts = Account.where(account_industry_id: industries_ids).not_gift.normal_account
      accounts = accounts.limit(5) if Rails.env.development?
      accounts.each do |account|
        SmsOrder.create(account_id: account.id, plan_id: plan_id)
      end

      # V-领先专业版商户 每月赠送100条短信
      plan_id = 4
      accounts = Account.not_gift.normal_account.where(account_industry_id: 10000, account_product_id: [10003, 10006])
      accounts = accounts.limit(5) if Rails.env.development?
      accounts.each do |account|
        SmsOrder.create(account_id: account.id, plan_id: plan_id)
      end
    end

  end

  def cancel!
    update_attributes!(status: SmsOrder::CANCEL)
  end

  def delete!
    if succeed?
      return update_attributes!(status: SmsOrder::F_DELETE)
    else
      return update_attributes!(status: SmsOrder::T_DELETE)
    end
  end

  def payment!
    pending_payment = payments.wait_buyer_pay.first
    if pending_payment
      payment = pending_payment
    else
      payment = Payment.setup({
        payment_type_id: 10003,
        account_id: account_id,
        site_id: site_id,
        customer_id: site_id,
        customer_type: 'Site',
        paymentable_id: id,
        paymentable_type: 'SmsOrder',
        out_trade_no: order_no,
        amount: plan_cost.to_f / 100,
        subject: "充值 #{order_no}",
        body: "充值 #{order_no}",
        source: 'sms_order'
      })
    end

    payment
  end

  def domain_url
    if Rails.env.production? or Rails.env.staging?
      url = 'http://www.winwemedia.com'
    elsif Rails.env.testing?
      url = 'http://testing.winwemedia.com'
    elsif Rails.env.development?
      url = 'localhost:3000'
    end
    url
  end

  def options_pay_for(payment)
    raise '没有指定商家' unless account
    raise '请选择支付单' unless payment

    {
      :service => 'create_direct_pay_by_user',
      :return_url => "#{domain_url}/sms/orders/callback",
      :notify_url => "#{domain_url}/sms/orders/notify",
      :error_notify_url => "#{domain_url}/sms/orders/error_notify",
      :service_url => 'https://mapi.alipay.com/gateway.do?_input_charset=utf-8',
      :partner => SmsOrder::ALIPAY_ID,
      :_input_charset  => 'utf-8',
      :payment_type  => '1',
      :seller_email  => SmsOrder::ALIPAY_ACCOUNT_NAME,
      :out_trade_no  => payment.out_trade_no,
      :subject => payment.subject,
      :body  => payment.body,
      :total_fee => payment.amount
    }
  end

  def default_pay_options
    raise '没有指定商家' unless account
    {
      alipay_id: SmsOrder::ALIPAY_ID,
      alipay_key: SmsOrder::ALIPAY_KEY,
      seller_account_name: SmsOrder::ALIPAY_ACCOUNT_NAME,
      service_url: 'http://wappaygw.alipay.com/service/rest.htm?_input_charset=utf-8',
      callback_url: "#{domain_url}/sms/orders/callback",
      notify_url: "#{domain_url}/sms/orders/notify",
      merchant_url: "#{domain_url}/sms/orders/new"
    }
  end

  def direct_options(payment)
    raise '请选择支付单' unless payment
    req_data = [
      "<direct_trade_create_req>",
      "<subject>支付宝支付</subject>",
      "<out_trade_no>#{payment.out_trade_no}</out_trade_no>",
      "<total_fee>#{payment.amount}</total_fee>",
      "<seller_account_name>#{self.default_pay_options[:seller_account_name]}</seller_account_name>",
      "<call_back_url>#{self.default_pay_options[:callback_url]}</call_back_url>",
      "<notify_url>#{self.default_pay_options[:notify_url]}</notify_url>",
      "<merchant_url>#{self.default_pay_options[:merchant_url]}</merchant_url>",
      "</direct_trade_create_req>"
    ]

    {
      :service => 'alipay.wap.trade.create.direct',
      :format  => 'xml',
      :v => '2.0',
      :partner => self.default_pay_options[:alipay_id],
      :sec_id => 'MD5',
      :req_id  => Concerns::OrderNoGenerator.generate,
      :req_data  => req_data.join,
      :_input_charset  => 'utf-8',
    }
  end

  def auth_options(request_token, payment)
    raise 'request_token不存在' unless request_token
    raise '请选择支付单' unless payment

    req_data = "<auth_and_execute_req><request_token>#{request_token}</request_token></auth_and_execute_req>"

    {
      :service => 'alipay.wap.auth.authAndExecute',
      :format  => 'xml',
      :v => '2.0',
      :partner => default_pay_options[:alipay_id],
      :sec_id => 'MD5',
      :req_id  => Concerns::OrderNoGenerator.generate,
      :req_data  => req_data,
      :_input_charset  => 'utf-8',
    }
  end

  def get_request_token(payment)
    raise '请选择支付单' unless payment
    paras = direct_options(payment)

    sign = generate_md5(sort_str(paras))
    url = 'http://wappaygw.alipay.com/service/rest.htm?_input_charset=utf-8'

    result = RestClient.post(url, paras.merge(sign: sign))
    Nokogiri::XML(Rack::Utils.parse_query(result)['res_data']).css('request_token').text
    #rescue => error
    # logger.info "error: #{error}"
    #  ''
  end

  def generate_md5(str)
    raise '没有指定商家' unless account

    require "digest/md5"
    Digest::MD5.hexdigest(str.to_s + SmsOrder::ALIPAY_KEY)
  end

  def sort_str(options = {})
    array = []

    options.each do |k, v|
      next if k == 'service_url' or v.blank?

      array << "#{k}=#{v}"
    end

    array.sort.join('&')
  end


  # {
  #   "out_trade_no"=>"2013061611245693042",
  #   "trade_no"=>"2013061649540913",
  #   "trade_status"=>"TRADE_SUCCESS",
  #   "total_fee"=>"0.01",
  #   "payment_type"=>"1",
  #   "subject"=>"微力公社广告主账户充值",
  #   "body"=>"test",
  #   "quantity"=>"1",
  #   "price"=>"0.01",
  #   "discount"=>"0.00",
  #   "is_total_fee_adjust"=>"N",
  #   "use_coupon"=>"N",
  #   "gmt_create"=>"2013-06-16 11:25:23",
  #   "gmt_payment"=>"2013-06-16 11:25:42",
  #   "buyer_id"=>"2088202867703133",
  #   "buyer_email"=>"wenke.gd@gmail.com",
  #   "seller_id"=>"2088901213277282",
  #   "seller_email"=>"payment@winwemedia.com",
  #   "sign_type"=>"MD5",
  #   "sign"=>"37dcc918f11879a3eaf824f51bd3ec87",
  #   "notify_type"=>"trade_status_sync",
  #   "notify_id"=>"3c20120ec00bc7c2e5c909c2d394c3422q",
  #   "notify_time"=>"2013-06-16 11:29:16",
  # }
  def self.notify(data)
    alipay_params = {}

    Nokogiri::XML.parse(data).css('notify').children.each do |element|
      alipay_params[element.name] = element.text
      #logger.info "element #{element.name.to_sym} : #{element.text}"
    end

    logger.info "alipay_params #{alipay_params}"

    delete_attrs = alipay_params.keys - Payment.column_names
    delete_attrs.each {|attr| alipay_params.delete(attr) }

    logger.info "alipay_params #{alipay_params}"

    payment = where(out_trade_no: alipay_params['out_trade_no']).first

    return unless payment

    transaction do
      before_update_status = payment.trade_status

      payment.update_attributes!(alipay_params)

      unless [TRADE_SUCCESS, TRADE_FINISHED].include?(before_update_status)
        order = payment.paymentable
        if order
          account = order.pay!
          if order.is_a?(VipRechargeOrder)
            order.vip_user.increase_amount!(order.amount, '充值', {direction: '3', description: '支付宝充值'})
          end
        end
      end

      payment
    end
  end

  def rqrcode(str = nil)
    #require 'RMagick'

    url = "#{M_HOST}/#{str}" if str.present?

    rqrcode = nil

    1.upto(12) do |size|
      begin
        rqrcode = RQRCode::QRCode.new(url, :size => size, :level => :h ).to_img.resize(258, 258)
        break
      rescue
      end
    end

    img = Magick::Image::read_inline(rqrcode.to_data_url).first #二维码作为背景图
    #if self.logo?
    #  mark = Magick::ImageList.new
    #  mark.read(logo.current_path)
    #  img = img.composite(mark.resize(60, 60), 99, 99, Magick::OverCompositeOp)
    #end
    return img
  end

  def add_default_attrs
    self.date = Date.today
    self.account_id = site.account_id
    self.order_no = Concerns::OrderNoGenerator.generate

    # plan_name=xxx
    SmsOrder::PLANS[self.plan_id].each{|key, value| self[key] = value} if self.plan_id

    if self.giv?
      self.status = 1 # 赠送的套餐，订单直接设为已支付状态
      self.free_sms = SmsOrder::PLANS[self.plan_id][:plan_sms]
    end

    # 测试环境支付1分钱
    self.plan_cost = 1 unless Rails.env.production? || Rails.env.staging?
  end

  def set_to_succeed(is_true)
    return unless pending? || failure?

    if is_true
      transaction do
        update_attributes(status: SmsOrder::SUCCEED)
        site.update_attributes(pay_sms_count: site.pay_sms_count.to_i + SmsOrder::PLANS[plan_id][:plan_sms])
      end
    else
      update_attributes(status: SmsOrder::FAILURE)
    end
  end

end
