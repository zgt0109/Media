module ErrorHandler

  def self.included( base_class )
    base_class.instance_eval do
      unless Rails.env.development?
        include ExceptionLogger::ExceptionLoggable
        rescue_from Exception, with: :winwemedia_log_exception_handler
      end
    end
  end

  protected
    def winwemedia_log_exception_handler(exception)
      case exception
        when ActiveRecord::RecordNotFound then render_404
        when ActionView::MissingTemplate  then render_404
        else
          log_exception_handler(exception)
      end
    end

    def render_404
      render layout: false, file: 'public/404_mobile', formats: :html, status: 404
    end

end
