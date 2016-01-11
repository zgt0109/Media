class Mobile::Wmall::BaseController < Mobile::BaseController
  layout "mobile/wmall"
  before_filter :set_seo, :cors_set_access_control_headers#, :current_mall
  helper_method :auth_params

  def auth_params
    {
      site_id: session[:site_id],
      user_id: session[:user_id]
    }.keep_if{|_,v| v.present?}
  end

  def set_seo(titles = nil)
    @current_wmall_titles = titles || %w(微商圈)
  end

  def current_mall
    @current_mall = @site.mall || @site.create_mall
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
  end
end
