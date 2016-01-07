class Pro::BusineAssistantsController < Pro::BusineBaseController

  def index
    @assistants = Assistant.enabled.circles.order('sort ASC')
  end

end
