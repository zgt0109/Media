class Site::PagesController < ActionController::Base
  layout 'site'

  def micro_channel
    @html_class = 'platform'
    @navigations = YAML.load_file("#{Rails.root}/config/navigations.yml")
  end
end