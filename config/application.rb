require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Wp
  class Application < Rails::Application

    config.paths['config/routes'] +=  Dir["#{Rails.root}/config/routes/*.rb"]
    config.i18n.enforce_available_locales = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.exceptions_app = self.routes
    # Custom directories with classes and modules you want to be autoloadable.
    #config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/api)
    config.autoload_paths += %w(lib app/api app/models/payment_settings app/models/concerns app/controllers/concerns app/validators app/services).map { |path| "#{Rails.root}/#{path}" }
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = 'zh-CN'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = false

    # Enable the asset pipeline
    config.assets.enabled = true

    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    }

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.assets.paths << Rails.root.join('app', 'assets', 'flash')
    # config.assets.precompile += %w( app.css app/app.js )
    # config.assets.precompile += Ckeditor.assets.select { |path| path =~ %r(/lang/) ? path =~ /(zh-cn|en)\.js/i : true }
    config.assets.precompile += %w[
      application.css application_1.css application_2.css ace.min.css font/font-awesome.min.css
      jquery.js jquery-ui.js jquery_ujs.js application.js address.js com.js lib/bootstrap.min.js
      bootstrap-editable.js
      micro_shop/micro_shop.css micro_shop/microshop_app.js micro_shop/ace-extra.min.js
      shake_site/template-1.css shake_site/template-2.css
      wx_wall.css wx_wall.js shake.js vscene.js
      jscolor/jscolor.js msdropdown/jquery.dd.min.js msdropdown/dd.css
      ace.min.css jsinhead.js jquery-fileupload/basic.js lib/validators.js
      button_apply_now.png
      home.css  sessions.css yeahsite.css home.js sessions.js yeahsite.js
      vip/vcard.css vip/vcard.js lib/jquery-ui.js
    ]
    config.assets.precompile += Dir['app/assets/javascripts/mobile/**/*.js'].map{ |x| x.sub('app/assets/javascripts/', '') }
    config.assets.precompile += Dir['app/assets/stylesheets/mobile/**/*.css'].map{ |x| x.sub('app/assets/stylesheets/', '') }
    config.assets.precompile += Dir['app/assets/stylesheets/shake_site/template-*.css'].map{ |x| x.sub('app/assets/stylesheets/', '') }
    config.assets.precompile += Dir['app/assets/javascripts/merchant_app/*.js'].map{ |x| x.sub('app/assets/javascripts/', '') }
    config.assets.precompile += Dir['app/assets/stylesheets/merchant_app/*.css'].map{ |x| x.sub('app/assets/stylesheets/', '') }
    config.assets.precompile += Dir['app/assets/javascripts/v5/**/*.js'].map{ |x| x.sub('app/assets/javascripts/', '') }
    config.assets.precompile += Dir['app/assets/stylesheets/v5/**/*.css'].map{ |x| x.sub('app/assets/stylesheets/', '') }
    config.assets.precompile += Dir['app/assets/javascripts/v5.1/**/*.js'].map{ |x| x.sub('app/assets/javascripts/', '') }
    config.assets.precompile += Dir['app/assets/stylesheets/v5.1/**/*.css'].map{ |x| x.sub('app/assets/stylesheets/', '') }
    config.assets.precompile += Dir['app/assets/images/mobile/wcard/*.*'].map{ |x| x.sub('app/assets/images/', '') }

    config.generators do |g|
      g.test_framework :rspec
      g.javascripts false
      g.stylesheets false
      g.jbuilder false
      # g.assets false
      g.helper false
      g.orm :active_record
    end
  end
end

Time::DATE_FORMATS.merge!(
  default: '%Y-%m-%d %H:%M',
  time: '%H:%M:%S',
  date: '%Y-%m-%d'
  #:date_time12  => "%m/%d/%Y %I:%M%p",
  #:date_time24  => "%m/%d/%Y %H:%M"
)
require "pp"
require 'date'
require "qi_niu/qiniu"
require "qi_niu/carrierwave"
require 'nong_li'
include NongLi
include QiNiu
include ImageExist
require 'weixinpay'
require 'acts_as_wx_media'
