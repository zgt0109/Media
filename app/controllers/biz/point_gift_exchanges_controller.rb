class Biz::PointGiftExchangesController < Biz::VipController

  def index
    @search    = current_site.point_gift_exchanges.latest.includes(:vip_user).includes(:point_gift).search(params[:search])
    @exchanges = @search.page(params[:page])
  end

end