class PaymentSettingsController < ApplicationController
  before_filter do
    @partialLeftNav = "/layouts/partialLeftSys"
  end

  before_filter :fetch_payment_settings, only: [:index, :enable, :disable]

  def edit
    @payment_setting = current_site.payment_settings.find(params[:id])
    render layout: 'application_pop'
  end

  def new
    @payment_setting = current_site.payment_settings.new(payment_type_id: params[:payment_type_id] || 10001)
    render layout: 'application_pop'
  end

  def create
    @payment_setting = current_site.payment_settings.new(params[:payment_setting])
    if @payment_setting.save
      flash[:notice] = '保存成功'
      render inline: "<script>window.parent.location.href = '#{payment_settings_url}';</script>"
    else
      flash[:alert] = "保存失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def update
    @payment_setting = current_site.payment_settings.find(params[:id])
    if @payment_setting.update_attributes(params[:payment_setting])
      flash[:notice] = '更新成功'
      render inline: "<script>window.parent.location.href = '#{payment_settings_url}';</script>"
    else
      flash[:alert] = "更新失败"
      render action: 'edit', layout: 'application_pop'
    end
  end

  def enable
    @payment_setting = current_site.payment_settings.find(params[:id])
    if @payment_setting.proxy_yeepay?
      @payment_setting.enable! if current_user.pay_account.normal?
      yeepay =  current_site.payment_settings.yeepay.first
      yeepay.disable! if yeepay.present?
    elsif @payment_setting.proxy_alipay?
      alipay =  current_site.payment_settings.alipay.first
      @payment_setting.enable! if current_user.pay_account.normal?
      alipay.disable! if alipay.present?
    elsif @payment_setting.yeepay?
      @payment_setting.enable!
      proxy_yeepay =  current_site.payment_settings.proxy_yeepay.first
      proxy_yeepay.disable! if proxy_yeepay.present?
    elsif @payment_setting.alipay?
      @payment_setting.enable!
      proxy_alipay =  current_site.payment_settings.proxy_alipay.first
      proxy_alipay.disable! if proxy_alipay.present?
    else
      @payment_setting.enable!
    end

    if @payment_setting.enabled?
      @type, @notice = "info",  '操作成功'
    else
      @type, @notice = "waring",  '操作失败'
    end
    respond_to do |format|
      format.js {render 'payments.js' }
    end
  end

  def disable
    @payment_setting = current_site.payment_settings.find(params[:id])
    if @payment_setting.disable!
      @type, @notice = "info",  '操作成功'
    else
      @type, @notice = "waring",  '操作失败'
    end
    respond_to do |format|
      format.js {render 'payments.js' }
    end
  end

  private
    def fetch_payment_settings
      @payment_settings = current_site.payment_settings
      @payment_settings = [
        @payment_settings.wxpay.first || @payment_settings.new(payment_type_id: 10001),
        @payment_settings.yeepay.first || @payment_settings.new(payment_type_id: 10002),
        @payment_settings.alipay.first || @payment_settings.new(payment_type_id: 10003),
        # @payment_settings.tenpay.first || @payment_settings.new(payment_type_id: 10004),
        # @payment_settings.tenpay.first,
        @payment_settings.proxy_yeepay.first
        # @payment_settings.proxy_alipay.first
      ].compact
    end

end
