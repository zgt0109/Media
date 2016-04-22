# encoding: utf-8
class Payment::Alipay < Payment::Base
  include PaymentAlipayable

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

  scope :active, where(trade_status: [TRADE_SUCCESS, TRADE_FINISHED])

  def self.setup(options = {})
    transaction do
      create!({
        payment_type: 10003,
        customer_id: options[:customer_id],
        customer_type: options[:customer_type],
        paymentable_id: options[:paymentable_id],
        paymentable_type: options[:paymentable_type],
        out_trade_no: options[:out_trade_no],
        amount: options[:amount],
        subject: options[:subject],
      })
    end
  end

  def generate_md5(str)
    raise '没有指定商家' unless site

    require "digest/md5"
    Digest::MD5.hexdigest(str.to_s + site.alipay_key)
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
      domain_url = 'http://dev.winwemedia.com'
    end

    {
      alipay_id: site.alipay_id,
      alipay_key: site.alipay_key,
      seller_account_name: site.alipay_account_name,
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

    now = Time.now
    req_id = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join

    {
      :service => 'alipay.wap.trade.create.direct',
      :format  => 'xml',
      :v => '2.0',
      :partner => default_pay_options[:alipay_id],
      :sec_id => 'MD5',
      :req_id  => req_id,
      :req_data  => req_data.join,
      :_input_charset  => 'utf-8',
    }
  end

  def auth_options(request_token)
    raise 'request_token不存在' unless request_token

    req_data = "<auth_and_execute_req><request_token>#{request_token}</request_token></auth_and_execute_req>"

    now = Time.now
    req_id = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join

    {
      :service => 'alipay.wap.auth.authAndExecute',
      :format  => 'xml',
      :v => '2.0',
      :partner => default_pay_options[:alipay_id],
      :sec_id => 'MD5',
      :req_id  => req_id,
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

  private

  # just for testing
  def generate_out_trade_no
    if self.out_trade_no.blank?
      now = Time.now
      self.out_trade_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
    end
  end
end
