class Biz::VipApiSettingsController < ApplicationController
  before_filter :find_vip_api_setting, except: [:spec]
  before_filter do
    @partialLeftNav  = 'layouts/partialLeftAPI'
  end

  def index
    @vip_card = current_user.vip_card
    @vip_api_setting ||= @vip_card.create_vip_api_setting(auth_username: SecureRandom.hex[0, 12], auth_password: SecureRandom.hex)
  end

  def update
    if @vip_api_setting.update_attributes( params[:vip_api_setting] )
      redirect_to :back, notice: "保存成功"
    else
      redirect_to :back, notice: "保存失败，#{@vip_api_setting.errors.full_messages.join("，")}"
    end
  end

  def toggle_status
    status = @vip_api_setting.enabled? ? 0 : 1
    @vip_api_setting.update_column :status, status
    render js: 'showTip("success", "操作成功");$(".openOrClose-pluin").toggleClass("pluin-close pluin-open");'
  end

  private
    def find_vip_api_setting
      return redirect_to vip_cards_url unless current_user.vip_card
      
      @vip_api_setting = current_user.vip_card.vip_api_setting
    end
end