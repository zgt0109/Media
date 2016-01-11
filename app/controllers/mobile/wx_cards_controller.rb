class Mobile::WxCardsController < Mobile::BaseController
  # skip_before_filter :auth, :authorize
  before_filter :block_non_wx_browser
  before_filter :get_share_image, only: [:index]
  
  layout 'mobile/wx_cards'

  def index
    @wx_cards = @site.cards.card_pass_check.unexpired.latest.page(params[:page])
    respond_to do |format|
      format.html
      format.json { render json: {wx_cards: show_card(@wx_cards) } }
    end
  end

  private
    def get_share_image
      @activity = Activity.find(params[:aid])
      @share_image = @activity.qiniu_pic_url || @activity.default_pic_url
    rescue => e
      @share_image = qiniu_image_url(Concerns::ActivityQiniuPicKeys::KEY_MAPS[76])
    end

    def show_card(wx_cards)
      @wx_cards.map do |card|
        card.title_with_type(@wx_user) if card.sku_quantity > card.consumes.show.count
      end
    end

end