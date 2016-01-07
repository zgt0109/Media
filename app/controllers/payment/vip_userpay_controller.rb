class Payment::VipUserpayController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :verify_authenticity_token, only: [:pay, :callback, :notify]

  def pay
  end

  def callback
    out_trade_no = params['out_trade_no']
    payment = Payment::VipUserpay.where(out_trade_no: out_trade_no).first
    data = params

    if payment.present?
      if params[:status] == "1"
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
    out_trade_no = params['out_trade_no']
    payment = Payment::VipUserpay.where(out_trade_no: out_trade_no).first

    if payment.present? and params["status"] == "1"
      payment.paid_success!(params) if payment.pending?

      payment.notify_push
      return render text: "success"
    end

    render json: {result: "failure"}
  end
end
