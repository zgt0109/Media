# encoding: utf-8
class Payment < ActiveRecord::Base
  include Paymentable
  include PaymentPaymentSyncable

  validates :subject, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }

  belongs_to :account
  belongs_to :customer, polymorphic: true
  belongs_to :paymentable, polymorphic: true

  before_save :generate_out_trade_no

  # WAIT_BUYER_PAY 交易创建,等待买家付款。
  # TRADE_CLOSED 1.在指定时间段内未支付时关闭的交易; 2.在交易完成全额退款成功时关闭的交易。
  # TRADE_SUCCESS 交易成功,且可对该交易做操作,如:多级分润、退款等。
  # TRADE_PENDING 等待卖家收款(买家付款后,如果卖家账号被冻结)。
  # TRADE_FINISHED 交易成功且结束,即不可再做任何操作
  enum_attr :trade_status, :in => [
    ['WAIT_BUYER_PAY', '待付款'],
    ['TRADE_CLOSED', '已关闭'],
    ['TRADE_SUCCESS', '成功'],
    ['TRADE_PENDING', '等待卖家收款'],
    ['TRADE_FINISHED', '交易成功且结束'],
  ]

  enum_attr :payment_type_id, in: PaymentType::ENUM_ID_OPTIONS

  enum_attr :status, :in => [
    ['pending', 0, '待付款'],
    ['success', 1, '成功'],
  ]

  enum_attr :settle_status, :in => [
    ['not_settled', 0, '未结算'],
    ['has_settled', 1, '已结算']
  ]

  enum_attr :is_delivery, :in => [
    ['not_delivery', 0, '待发货'],
    ['delivery', 1, '已发货'],
  ]

  scope :active, where(trade_status: [TRADE_SUCCESS, TRADE_FINISHED])
  scope :proxy_pay, where(payment_type_id: [20001, 20002])
  scope :can_settle, ->{proxy_pay.success.not_settled.where(gmt_payment: Time.now - 100.years .. Time.now - 5.days)}

  def self.setup(options = {})
    transaction do
      create! options
    end
  end

  def update_pay_result options = {}
    transaction do
      update_attributes options
    end
  end

  #可提现金额
  def withdraw_amount
    (amount * (1 - settle_fee_rate)).to_f.round(2)
  end

  def settle_fee_rate
    account.pay_account.settle_fee_rate rescue 0.01
  end

  def wx_total_fee
    (amount * 100).to_i
  end

  # TODO 已不再使用，详情请查看model/payment/目录
  # start for yeepay
  def pay_options(params)
    pay_params = {
        'orderid' =>  out_trade_no,
        'transtime' =>  DateTime.now.to_i,
        'currency'  =>  156,
        'amount'  =>  (amount.to_f / 100).to_i,
        'productcatalog'=>  "7",# 1 虚拟产品 2 信用卡还款 3 公共事业缴费 4 手机充值 5 普通商品 6 慈善和社会公益服务 7 实物商品
        "userua" => params[:userua],
        'productname' =>  subject.to_s,
        'productdesc' =>  '易宝支付',
        'userip'  =>  params[:userip],
        'identityid'  =>  params[:identityid],
        'identitytype'  =>  0,
        'other'     =>  "MAC:00-EO-4C-6C-08-75",
    }
  end

  def pay!(params)
    update_attributes!(payment_type_id: 10003, status: params['status'], total_fee: params['amount'].to_f * 100, trade_no: params['yborderid'], pay_params: params.to_s)
  end
  # end for yeepay

  def has_prepay_id?
    prepay_id.present?
  end

  def save_prepay_id value
    update_attribute('prepay_id', value)
  end

  def get_pay_url(options={}, *args)
    case
    when self.wxpay?
      "#{PaymentSetting::WEIXIN_PAY_URL}?out_trade_no=#{self.out_trade_no}&account_id=#{self.account_id}&openid=#{self.open_id.presence}&showwxpaytitle=1"
    when self.tenpay?
      tenpay  = self.site.payment_settings.tenpay.first
      if tenpay.partner_key && tenpay.partner_key
        _options = {
          :subject => self.subject,
          :body => self.body,
          :total_fee => (self.amount * 100).to_i,
          :out_trade_no => self.out_trade_no
        }
        return generate_tenpay_url(_options, tenpay.partner_id, tenpay.partner_key, options)
      else
        raise "Account have no tenpay settings"
      end
    when yeepay? || proxy_yeepay?
      request = args[0]
      _options = {userua: request.user_agent, userip: options[:user_ip]}
      Payment::Yeepay.find(self.id).pay_url(_options)
    when alipay? || proxy_alipay?
      request = args[0]
      Payment::Alipay.find(self.id).pay_url({pay_request_url: request.base_url})
    when vip_userpay?
      Payment::VipUserpay.find(self.id).pay_url
    else
      raise "Account have no special payment settings"
    end
  end

  def self.source_hash
    {
      group_order: '微团购',
      booking_order: '微服务',
      vip_recharge: '会员充值',
      shop_order: '微餐饮/外卖',
      donation_order: '微公益',
      ec: '微电商',
      hotel: '微酒店',
    }
  end

  def self.source_options
    collection = []
    source_hash.each { |k,v| collection << [v, k] }
    collection
  end

  def source_name
    Payment.source_hash.fetch(source.to_sym) rescue nil
  end

  ## Alipay only
  def generate_md5(str)
    raise '没有指定商家' unless site
    alipay_key = site.alipay_key || (site.payment_settings.alipay.first.partner_key rescue nil)
    raise '没有指定支付方式' unless alipay_key

    require "digest/md5"
    Digest::MD5.hexdigest(str.to_s + alipay_key)
  end

  def sort_str(options = {})
    array = []

    options.each { |k, v| array << "#{k}=#{v}" }

    array.sort.join('&')
  end

  def default_pay_options
    raise '没有指定商家' unless site

    if Rails.env.production?
      domain_url = 'http://www.winwemedia.com'
    elsif Rails.env.staging?
      domain_url = 'http://staging.winwemedia.com'
    else
      domain_url = 'http://testing.winwemedia.com'
    end
    alipay_id = (site.payment_settings.alipay.first.partner_id rescue nil)
    alipay_key = (site.payment_settings.alipay.first.partner_key rescue nil)
    seller_account_name = (site.payment_settings.alipay.first.partner_account rescue nil)

    {
      alipay_id: alipay_id,
      alipay_key: alipay_key,
      seller_account_name: seller_account_name,
      service_url: 'http://wappaygw.alipay.com/service/rest.htm?_input_charset=utf-8',
      callback_url: "#{domain_url}/payments/callback",
      notify_url: "#{domain_url}/payments/notify",
      merchant_url: "#{domain_url}/payments/merchant"
    }
  end

  def direct_options
    req_data = [
      "<direct_trade_create_req>",
      "<subject>支付宝支付</subject>",
      "<out_trade_no>#{out_trade_no}</out_trade_no>",
      "<total_fee>#{amount}</total_fee>",
      "<seller_account_name>#{default_pay_options[:seller_account_name]}</seller_account_name>",
      "<call_back_url>#{default_pay_options[:callback_url]}</call_back_url>",
      "<notify_url>#{default_pay_options[:notify_url]}</notify_url>",
      "<merchant_url>#{default_pay_options[:merchant_url]}</merchant_url>",
      "</direct_trade_create_req>"
    ]

    {
      :service => 'alipay.wap.trade.create.direct',
      :format  => 'xml',
      :v => '2.0',
      :partner => default_pay_options[:alipay_id],
      :sec_id => 'MD5',
      :req_id  => Concerns::OrderNoGenerator.generate,
      :req_data  => req_data.join,
      :_input_charset  => 'utf-8',
    }
  end

  def auth_options(request_token)
    raise 'request_token不存在' unless request_token

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

  def get_request_token
    paras = direct_options

    sign = generate_md5(sort_str(paras))
    url = 'http://wappaygw.alipay.com/service/rest.htm?_input_charset=utf-8'

    result = RestClient.post(url, paras.merge(sign: sign))
    Nokogiri::XML(Rack::Utils.parse_query(result)['res_data']).css('request_token').text
  #rescue => error
    # logger.info "error: #{error}"
  #  ''
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
        payment.update_attributes!(payment_type_id: 10003, status: 1)

        order = payment.paymentable
        order.recharge! if order && order.is_a?(VipRechargeOrder)
      end

      payment
    end
  end

  private

    # just for testing
    def generate_out_trade_no
      if self.out_trade_no.blank?
        self.out_trade_no = Concerns::OrderNoGenerator.generate
      end
    end

    # 用于创建财付通相关的 url
    def generate_tenpay_url(options, pid, jkey, request_options)
      _options = {
        :return_url => request_options[:tenpay_callback],
        :notify_url => request_options[:tenpay_notify],
        :spbill_create_ip => request_options[:user_ip],
      }.merge(options)

      JaslTenpay::Service.create_interactive_mode_url(_options, pid, jkey)
    end
end
