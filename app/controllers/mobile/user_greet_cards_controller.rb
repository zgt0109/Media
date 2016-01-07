class Mobile::UserGreetCardsController < Mobile::BaseController
  layout 'mobile/greets'
  before_filter :block_non_wx_browser

  def index
    @activity = Activity.find(params[:activity_id])
    @greet = @activity.greet
  end

  def show
    @user_greet_card = UserGreetCard.find(params[:id])
    unless @user_greet_card.greet_card.try(:used?)
      return render text: '贺卡不存在'
    end
  end

  def create
    @user_greet_card = UserGreetCard.new(params[:user_greet_card])
    @user_greet_card.save!
    redirect_to mobile_greet_card_user_greet_card_url(supplier_id: @user_greet_card.greet_card.greet.supplier_id, greet_card_id: @user_greet_card.greet_card_id, id: @user_greet_card.id)
    #/:supplier_id/greet_cards/:greet_card_id/user_greet_cards/:id(.:format)
  end

end
