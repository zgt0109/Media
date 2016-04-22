# encoding: utf-8
class PaymentsController < ApplicationController
  skip_before_filter *ADMIN_FILTERS, :only => [:callback, :notify, :merchant, :alipayapi,:payment_request]
  protect_from_forgery :except => [:create, :callback, :notify, :merchant, :alipayapi,:payment_request]
  # skip_before_filter :verify_authenticity_token, :except => [:create]
  layout 'application_gm'

  def callback
    payment = Payment.where(out_trade_no: params[:out_trade_no]).first
    paymentable =  payment.try(:paymentable)

    if paymentable.present?
      if paymentable.is_a?(GroupOrder)
        if params['status'].present? && params['status'] == '1'
          paymentable.pay! if paymentable.pending?
          #商圈团购增加统计
          $redis.rpush("wmall:shop:#{paymentable.try(:group_item).try(:groupable_id)}:group:order", paymentable.id) if paymentable.try(:group_item).try(:groupable_type) == "Wmall::Shop"

          #redirect_to mobile_group_order_path(paymentable.site_id, paymentable)
          redirect_to mobile_group_orders_url(paymentable.site_id)
        else
          # render text: '支付失败'
          #redirect_to mobile_group_order_path(paymentable.site_id, paymentable)
          redirect_to mobile_group_orders_url(paymentable.site_id)
        end
      elsif paymentable.is_a?(VipRechargeOrder)
        openid = paymentable.vip_user.user.wx_user.openid rescue nil
        redirect_to recharge_back_app_vips_path(openid: openid, site_id: paymentable.site_id, order_id: paymentable.id)
      elsif paymentable.is_a?(ShopOrder)
        if params['status'].present? && params['status'] == "1"
          #标记为支付成功!
          paymentable.pay!
          redirect_to success_mobile_shop_order_url(site_id: paymentable.site_id, id: paymentable.id)
        else
          # paymentable.unpay!
          redirect_to mobile_shop_order_url(site_id: paymentable.site_id, id: paymentable.id)
        end
      elsif paymentable.is_a?(DonationOrder)
        if params['status'].present? && params['status'] == "1"
          #标记为支付成功!
          paymentable.paid!
          redirect_to success_mobile_donation_orders_url(site_id: paymentable.site_id, aid: paymentable.donation.activity_id)
        else
          # paymentable.unpay!
          redirect_to mobile_donation_order_url(site_id: paymentable.site_id, aid: paymentable.donation.id)
        end
      end
    else
      render text: '支付成功'
    end
  end

  def notify
    if params[:notify_data].present?
      if Payment.notify(params[:notify_data])
        return render text: 'success'
      else
        return render text: 'fail'
      end
    else
      if params['status'].present? && params['status'] == '1'
        payment = Payment.where(out_trade_no: params[:out_trade_no]).first
        paymentable = payment.try(:paymentable)
        if paymentable.present?
          paymentable.pay! if paymentable.is_a?(GroupOrder) and paymentable.pending? and payment.success?

          paymentable.recharge! if paymentable.is_a?(VipRechargeOrder) and paymentable.pending?

          paymentable.paid! if paymentable.is_a?(DonationOrder) and paymentable.pending?

          if paymentable.is_a?(ShopOrder)
            #标记为支付成功!
            paymentable.pay!
            paymentable.shop_qrcode_amount
            #paymentable.update_product_qty
            paymentable.send_message
          end
          return render text: 'success'
        end
      end
    end
    render text: '支付失败'
  end

  def payment_request
    @account = Account.where(id: params[:account_id]).first
    return render json: {errcode: 001, errmsg: "account not found"} unless @account

    @payment = Payment.where(out_trade_no: params[:out_trade_no]).first
    tenpay_hash = { tenpay_callback: tenpay_callback_url.to_s, tenpay_notify: tenpay_notify_url.to_s}
    tenpay_hash[:user_ip] = params[:user_ip].present? ? params[:user_ip] : request.ip

    @payment ||= Payment.setup({
      account_id: @account.id,
      site_id: params[:site_id],
      payment_type_id: params[:payment_type_id],
      customer_id: params[:customer_id],
      customer_type: params[:customer_type],
      paymentable_id: params[:paymentable_id],
      paymentable_type: params[:paymentable_type].to_s,
      out_trade_no: params[:out_trade_no],
      amount: params[:amount],
      subject: params[:subject].to_s,
      body: params[:body].to_s,
      notify_url: params[:notify_url],
      callback_url: params[:callback_url],
      merchant_url: params[:merchant_url],
      state: params[:state],
      source: params[:source],
      open_id: params[:open_id],
      pay_params: params.to_json
    })

    if @payment.success?
      return render json: {errcode: 003, errmsg: "the order has been paid"} if @payment.success?
    end

    begin
      render json: {errcode: 0, pay_url: @payment.get_pay_url(tenpay_hash, request)}
    rescue => error
      SiteLog::Payment.logger.error "handle payment_request failure: #{params.inspect} #{error.message} #{error.backtrace.inspect}"
      render json: {errcode: 1, remark: "#{error.message}"}
    end
  end

  def merchant
    _real_merchant_url = Base64.decode64(params[:real_merchant_url])

    if _real_merchant_url =~ URI::regexp
      redirect_to _real_merchant_url
    else
      redirect_to "http://m.winwemedia.com/winwemedia"
    end
  end
  
end
