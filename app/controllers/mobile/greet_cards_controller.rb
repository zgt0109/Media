class Mobile::GreetCardsController < Mobile::BaseController
  layout 'mobile/greets'
  before_filter :block_non_wx_browser

  def index
    @activity = Activity.find(params[:activity_id])
    @greet = @activity.greet
  end

  def show
    @greet_card = GreetCard.find(params[:id])
    @user_greet_card = UserGreetCard.new(greet_card_id: @greet_card.id, wx_user_id: session[:wx_user_id])
  end

end
