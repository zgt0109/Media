module UtilityHelper
  def add_params_to_url(url, path, params)
    if url.present? and params.present?
      uri = URI.parse(url)
      query_hash = Rack::Utils.parse_query(uri.query)
      query_hash.merge!(params)
      #uri.query = Rack::Utils.build_query(query_hash) #cannot use to nest_hash
      uri.query = query_hash.to_param
      uri.path = path
      uri.to_s
    end
  end

  def side_menu_group_status(controllers=[], active = "cur")
    if controllers.present? and controllers.any?{|controller| controller.include?(params[:controller])}
      active
    else
      nil
    end
  rescue => e
    logger.error "side menu status detection error occured: #{e.backtrace}"
    nil
  end

  def side_menu_status(controller = nil,action = nil, params_hash = {}, active = "cur")
    if controller.present?
      return nil unless controller == params[:controller]
    end
    if action.present?
      return nil unless action == params[:action]
    end
    if params_hash.present?
      return nil unless params_hash.keys.all?{|k| params.has_key?(k) }
    end
    return active
  #rescue => e
  #  logger.error "side menu status detection error occured: #{e.backtrace}"
  #  nil
  end
end
