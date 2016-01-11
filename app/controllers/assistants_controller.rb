class AssistantsController < ApplicationController

  def index
    type = params[:type] == 'games' ? 'games' : 'helpers'
    @assistants = Assistant.enabled.send(type).order('sort ASC')
  end

  def toggle
    attrs = { assistant_id: params["id"], site_id: current_site.id }
    @assistant_site = AssistantsSite.where(attrs).first
    if @assistant_site
      @assistant_site.destroy
    else
      @assistant_site = AssistantsSite.create(attrs)
    end
    render nothing: true
  end

end
