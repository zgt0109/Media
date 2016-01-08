class Mobile::EcShopsController < Mobile::BaseController
  include WxReplyMessage

  layout 'mobile/ec'
  before_filter :set_branch

  def index
    @page_class = 'index'
    @ec_ads = @shop.ads if @shop
    redirect_to wshop_root_url(wx_mp_user_open_id: @wx_mp_user.try(:openid),wx_user_open_id: @wx_user.try(:openid))
  end

  def show
    @page_class = "detail"
    @item = EcItem.find(params[:id])
    @item_pictures = [@item]
    redirect_to wshop_root_url(wx_mp_user_open_id: @wx_mp_user.try(:openid),wx_user_open_id: @wx_user.try(:openid))
  end

  def member
    @page_class = 'member'
    redirect_to wshop_root_url(wx_mp_user_open_id: @wx_mp_user.try(:openid),wx_user_open_id: @wx_user.try(:openid))
  end

  private

  def set_branch
    @shop = @supplier.ec_shop
    return render text: '页面不存在' unless @shop

    @categories = @shop.categories.root.normal.order(:sort_order)
  end

end

