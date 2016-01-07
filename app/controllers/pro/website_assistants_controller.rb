class Pro::WebsiteAssistantsController < ApplicationController
  layout 'application_gm'
  def index
    @assistants = Assistant.enabled.lives.order('sort ASC')
  end
end
