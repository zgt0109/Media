class App::VipUserPaymentsController < ActionController::Base
  layout "vip_user_payment"
  before_filter :set_vip_user_payment, only: [:update]

  def payment
    result = {}
    fields_allowed = %w(wx_mp_user_id supplier_id open_id out_trade_no amount subject body source callback_url notify_url merchant_url)
    @trade_data = HashWithIndifferentAccess.new(params.slice(*fields_allowed))
    @vip_user_payment = VipUserPayment.new(@trade_data)

    if trade_params_valid?(@trade_data)
      if (vip_user = VipUserPayment.detected_vip_user(@trade_data[:wx_mp_user_id], @trade_data[:open_id])).present?
        if vip_user.password_digest.present?
          @vip_user_payment = VipUserPayment.build_and_validate(vip_user, @trade_data)

          if @vip_user_payment.save
            #password
            return render "confirm_trade"
          else
            result = {code: "-1", remark: "交易数据无效"}
          end
        else
          # TODO set vip_user password
          #redirect_to :set_vip_user_password , alert: "请先设置支付密码"
          result = {code: "-1", remark: "请先设置支付密码"}
          return redirect_to passwd_app_vips_path(wxmuid: @trade_data[:wx_mp_user_id], return_to: request.url, openid: @trade_data[:open_id])
        end
      else
        result = {code: "-1", remark: "您还没有申请会员卡，请先申请会员卡或用其他支付方式"}
      end
    else
      result = {code: "-1", remark: "无效的参数"}
    end

    flash[:error] = result[:remark]
    render "invalid_trade"
  end

  def update

    respond_to do |format|
      unless @vip_user_payment.is_a?(VipUserPayment)
        flash[:error] = "支付异常！"

        format.js   {render js: "$(function(){ alert('#{flash[:error]}')})" }
      else
        if @vip_user_payment.present? and @vip_user_payment.vip_user.authenticate(vip_user_payment_params[:password])
          @vip_user_payment.confirm_paid!

          format.js   {render "app/vip_user_payments/payment"}
        else
          flash[:error] = "密码错误"

          format.js   {render js: "$(function(){ alert('#{flash[:error]}')})" }
        end
      end
    end
  end

  def show
    flash[:error] = params[:errmsg]
    @vip_user_payment = VipUserPayment.where(id: params[:id]).first
  end

  def update_transfer_result
    @vip_user_payment = VipUserPayment.confirm_paid.find params[:id]

    case params[:errcode]
      when "0"
        @vip_user_payment.transfer_success!
        @vip_user_payment.notify_push
      when "-1"
        @vip_user_payment.transfer_failure!
      else
    end

    render js: %Q{window.location.href= '#{app_vip_user_payment_path(@vip_user_payment, errmsg: params[:errmsg])}'}
  end

  private
  def set_vip_user_payment
    @vip_user_payment = VipUserPayment.ready.where(id: params[:id]).first
  end

  def vip_user_payment_params
    require_fields = %w(password)
    params[:vip_user_payment].slice(*require_fields) if params[:vip_user_payment].present?
  end
  def trade_params_valid?(trade_data)
    required_fields = %w(wx_mp_user_id open_id out_trade_no amount subject)
    required_params = trade_data.slice(*required_fields)

    required_fields.all? do |trade_field|
      if required_params[trade_field].present?
        true
      else
        logger.warn "VipUserPayment trade_params #{trade_field} been required"
        false
      end
    end
  end
end
