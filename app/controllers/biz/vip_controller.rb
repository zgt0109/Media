class Biz::VipController < ApplicationController
  before_filter :require_vip_card

  private
  def require_vip_card
    redirect_to vip_cards_path, notice: '请先设置会员卡信息' unless current_site.vip_card
  end

  def set_vip_card
    @vip_card = current_site.vip_card
  end

  def fetch_activity_and_vip_card
    if current_site.vip_card
      @vip_card = current_site.vip_card
      @activity = @vip_card.activity
    else
      @activity = current_site.create_activity_for_vip_card
      @vip_card = @activity.vip_card
    end
  end
end
