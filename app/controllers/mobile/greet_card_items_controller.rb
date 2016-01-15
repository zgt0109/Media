class Mobile::GreetCardItemsController < Mobile::BaseController
  layout 'mobile/greets'
  before_filter :block_non_wx_browser

  def index
    @activity = Activity.find(params[:aid])
    @greet = @activity.greet
  end

  def show
    @greet_card_item = GreetCardItem.find(params[:id])
    unless @greet_card_item.greet_card.try(:used?)
      return render text: '贺卡不存在'
    end
  end

  def create
    @greet_card_item = GreetCardItem.new(params[:greet_card_item])
    @greet_card_item.save!
    redirect_to mobile_greet_card_greet_card_item_url(site_id: @greet_card_item.greet_card.greet.site_id, greet_card_id: @greet_card_item.greet_card_id, id: @greet_card_item.id)
  end

end
