class Payment::YeepayController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  skip_before_filter :verify_authenticity_token, only: [:pay, :callback, :notify]

  def pay
  end

  def new
  end

  def callback
    merchantaccount = params[:merchantaccount]
    SiteLog::Payment.logger.error "yeepay callback received: #{params.inspect}"

    if merchantaccount.present? and (yeepay_setting = YeepaySetting.where(partner_id: merchantaccount).first)
      data = yeepay_setting.crypto.decypt_data({ data: params[:data], encryptkey: params[:encryptkey] })
      status = data['status']

      if [1, 0].include? data['status']
        out_trade_no = data['orderid'].split("_").first
        payment = Payment::Yeepay.where(out_trade_no: out_trade_no).first
        if payment.present?
          case status
            when 1
              payment.paid_success!(data) if payment.pending?
            #when 0
            #  payment.paid_failure!(data) if payment.pending?
          end

          callback_uri = URI(payment.callback_url)
          callback_uri.query = payment.pay_result.to_param

          return redirect_to "#{callback_uri}"
        end
      end
    end
    render json: {result: 'pay_failure', remark: '支付失败'}
  end

  def notify
    render json: {result: "success"}
  end
end
