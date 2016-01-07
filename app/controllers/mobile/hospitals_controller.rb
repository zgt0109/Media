class Mobile::HospitalsController < Mobile::BaseController

  layout 'micro/hospitals'
  def default_url_options
    { :supplier_id => session[:supplier_id] }
  end

end