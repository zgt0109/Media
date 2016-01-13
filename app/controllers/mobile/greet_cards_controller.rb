class Mobile::GreetCardsController < Mobile::BaseController
  layout 'mobile/greets'
  before_filter :block_non_wx_browser

  def index
    @activity = Activity.find(params[:aid])
    @greet = @activity.greet
  end

  def show
    @greet_card = GreetCard.find(params[:id])
    @user_greet_card = GreetCardItem.new(greet_card_id: @greet_card.id, user_id: session[:user_id])
  end

end
