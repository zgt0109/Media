class Payment::AlipayController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :verify_authenticity_token, only: [:pay, :callback, :notify]

  def pay
  end

  def callback
    out_trade_no = params['out_trade_no']
    payment = Payment::Alipay.where(out_trade_no: out_trade_no).first
    data = params

    if payment.present?
      if params[:result] == "success"# and params[:trade_status] == "TRADE_SUCCESS"
        payment.paid_success!(data) if payment.pending?
      else
        #if payment.pending?
        #  payment.paid_failure!(data)
        #end
      end
      callback_uri = URI(payment.callback_url)
      callback_uri.query = payment.pay_result.to_param

      return redirect_to "#{callback_uri}"
    end

    render json: {result: 'pay_failure', remark: '支付失败'}
  end

  def notify
    notify_data = Hash.from_xml(params[:notify_data])["notify"] rescue {}
    notify_data = HashWithIndifferentAccess.new(notify_data)
    out_trade_no = notify_data['out_trade_no']
    payment = Payment::Alipay.where(out_trade_no: out_trade_no).first

    if payment.present? and notify_data["trade_status"] == "TRADE_FINISHED"
      payment.paid_success!(notify_data) if payment.pending?

      payment.notify_push
      return render text: "success"
    end

    render json: {result: "failure"}
  end
end
