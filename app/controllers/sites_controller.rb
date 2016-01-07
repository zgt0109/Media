# coding: utf-8
class SitesController < ApplicationController
  skip_before_filter *ADMIN_FILTERS
  before_filter -> { @html_class = params[:action] }, except: [:index]
  layout 'home', except: [:index]

  def index
    if current_user && current_user.is_a?(Supplier)
      redirect_to console_url
    else
      @dev_logs = DevLog.vcl.order('created_at desc').limit(4)
      @app_config = YAML.load_file("#{Rails.root}/config/app_config.yml")
      session[:image_code] = nil
    end
  end

  def oa
  end

  def yeahsite
  end
end
