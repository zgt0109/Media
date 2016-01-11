class Mobile::HospitalsController < Mobile::BaseController

  layout 'micro/hospitals'
  def default_url_options
    { :site_id => session[:site_id] }
  end

end