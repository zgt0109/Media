class App::VipApisController < App::VipsController
  layout 'app/vip'
  # layout false
  before_filter :require_enable_api_setting

  def vip_info
    # @vip_hash = { "姓名" => "张三", "生日" => "1982-12-04" }
    @vip_hash = @vip_api_setting.get_user_info( @vip_user.mobile ) rescue {'error' => true}
    # @vip_hash = @vip_api_setting.get_user_info( @vip_user.mobile )
    logger.info "会员信息：#{@vip_hash}"
    # @vip_hash['error']
    redirect_to info_app_vips_url if @vip_hash['error']
  end

  def vip_transactions
    startDate = params[:startDate].presence || Date.today.beginning_of_month.to_date.to_s
    endDate = Date.parse(startDate).end_of_month
    endDate = Date.today if endDate > Date.today
    @query = {
      mobile: @vip_user.mobile,
      startDate: startDate.to_s,
      endDate: endDate.to_s
    }

    @transactions = @vip_api_setting.get_transactions( @query )['data']
    logger.info "会员信息：#{@transactions}"
  rescue => e
    redirect_to :back, alert: "获取会员流水出错，#{e.message}"
  end

  private
    def require_enable_api_setting
      @vip_api_setting = @vip_card.vip_api_setting
      redirect_to vips_app_url, notice: "商户没有开通会员接口功能" unless @vip_api_setting.try(:enabled?)
    end
end
