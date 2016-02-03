# encoding: utf-8
class Payment::VipUserpay < Payment::Base
  delegate :default_params, to: "self.class"

  def paid_success!(params)
    params = HashWithIndifferentAccess.new(params)
    _attr_params = HashWithIndifferentAccess.new({
      status: 1,
      trade_status: 'TRADE_SUCCESS',
      gmt_payment: Time.now,
      order_msg: params.to_s
    })

    update_attributes!(_attr_params)
  end

  # TODO
  def paid_failure!(params)
  end

  def pay_options(params)
    params[:callback_url] ||= default_params['callback_url']
    params[:notify_url] ||= default_params['notify_url']

    pay_params = {
      account_id: account_id,
      open_id: open_id,
      out_trade_no: out_trade_no,
      amount: amount,
      subject: subject,
      body: body,
      source: source,
      callback_url: params[:callback_url],
      notify_url: params[:notify_url]
    }
  end

  def pay_url(params = {})
    _params = pay_options(params)

    uri = URI(Payment::VipUserpay.default_params[:pay_quest_url])
    uri.query = _params.to_param
    uri.to_s
  end

  class << self
    def default_params
      PAYMENT_CONFIG[:vip_user_pay]
    end
  end

end
