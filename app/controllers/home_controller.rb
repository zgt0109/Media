# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  include Biz::HighchartHelper

  skip_before_filter *ADMIN_FILTERS, except: [:console, :site_navigation, :helpers, :games, :account, :utility, :industry, :show_introduce]

  skip_before_filter :check_account_expire, :check_auth_tel#, only: [:index, :console, :account]

  # caches_page :about, :contact, :jobs, :kefu, :huiyuanka, :wlife, :solution, :navigation

  def index
    if current_user && current_user.is_a?(Supplier)
      redirect_to console_url
    else
      # @html_class = 'index'
      # @dev_logs = DevLog.vcl.order('created_at desc').limit(4)
      # @app_config = YAML.load_file("#{Rails.root}/config/app_config.yml")
      # @company_news = News.company.order('created_at desc').select("id,title,short_content,pic,created_at").limit(2)
      # @broadcast_news = News.broadcast.order('created_at desc').select("id,title,short_content,pic,created_at").limit(2)
      # @industry__news = News.industry_news.order('created_at desc').select("id,title,short_content,pic,created_at").limit(2)
      # session[:image_code] = nil
      redirect_to sign_in_path
    end
  end

  def console
    return redirect_to platforms_url unless current_user.wx_mp_user

    respond_to do |format|
      format.html do
        @activities = current_user.activities.active.unexpired.where(activity_type_id: ActivityType::ACTIVITY_IDS)
        render layout: 'application'
      end
      format.js do
        @piwik_sites = PiwikSite.where(:supplier_id => current_user.id)
        @total_vip_users = current_user.vip_users.normal_and_freeze
        @all_wx_requests = WxRequest.where(supplier_id: current_user.id).select('date, increase, subscribe')

        total_pv_count = @piwik_sites.sum(:nb_actions)
        total_uv_count = @piwik_sites.sum(:nb_visits)
        if Rails.env.production?
          total_piwik_sites_2014 = ActiveRecord::Base.connection.execute("select sum(nb_actions), sum(nb_visits) from piwik_sites_2014 where supplier_id=#{current_user.id}").first
          total_piwik_sites_2015 = ActiveRecord::Base.connection.execute("select sum(nb_actions), sum(nb_visits) from piwik_sites_2015 where supplier_id=#{current_user.id}").first
          total_pv_count = total_pv_count + total_piwik_sites_2014[0].to_i + total_piwik_sites_2015[0].to_i
          total_uv_count = total_uv_count + total_piwik_sites_2014[1].to_i + total_piwik_sites_2015[1].to_i
        end
        @total_pv_count = total_pv_count
        @total_uv_count = total_uv_count
        
        @yesterday_piwik_site = @piwik_sites.where(date: Date.yesterday).first

        @today = Date.today
        @total_vip_user_count = @total_vip_users.count
        @yesterday_vip_user_count = @total_vip_users.where("date(created_at) = ?", Date.yesterday).count

        total_subscribes = @all_wx_requests.sum(:increase)
        if Rails.env.production?
          total_subscribes_2014 = ActiveRecord::Base.connection.execute("select sum(increase) from wx_requests_2014 where supplier_id=#{current_user.id}").first[0] || 0
          total_subscribes_2015 = ActiveRecord::Base.connection.execute("select sum(increase) from wx_requests_2015 where supplier_id=#{current_user.id}").first[0] || 0
          total_subscribes = total_subscribes + total_subscribes_2014 + total_subscribes_2015
        end
        @total_subscribe_count = total_subscribes

        @yesterday_wx_request  = @all_wx_requests.where(date: Date.yesterday..Date.today).first
        @yesterday_subscribe_count = @yesterday_wx_request.try(:increase).to_i

        @pv_categories, @pv_data = @piwik_sites.get_recent_data(current_user.id, 'nb_actions', 'recent_30')
        @uv_categories, @uv_data = @piwik_sites.get_recent_data(current_user.id, 'nb_uniq_visitors', 'recent_30')

        @vip_user_categories, @vip_user_data, @start_time, @end_time, min_tick = cube_chart_data_for_datacube_vip_card(@total_vip_users, 'one_months', Date.yesterday)

        @subscribe_data = {}
        @subscribe_categories = []
        @dates = ((Date.yesterday - 30)..Date.yesterday).to_a
        @dates.each do |date|
          @subscribe_data[date.to_s] = 0
          @subscribe_categories << date.try(:strftime, "%m/%d")
        end

        requests = @all_wx_requests.where(["date >= ? and date <= ?", @dates.first, @dates.last])
        requests.each do |r|
          @subscribe_data[r.date.to_s] = r.subscribe
        end
      end
    end
  end

  def account
    return redirect_to root_path unless current_user
    return redirect_to platforms_url unless current_user.wx_mp_user

    @wx_mp_user = current_user.wx_mp_user
    @partialLeftNav = "/layouts/partialLeftSys"
    render layout: 'application'
  end

  def navigation
    @html_class = 'platform'
    @navigations = YAML.load_file("#{Rails.root}/config/navigations.yml")
  end

  def agents
    @search = Agent.search(params[:search])
    if @search.name_eq.present?
      @agents = @search.order('created_at desc')
    else
      @agents = nil
    end
  rescue => error
    @agents = nil
  end

  def wlife
    @supplier_apply = SupplierApply.new(apply_type: SupplierApply::AGENCY)
    @app_config = YAML.load_file("#{Rails.root}/config/app_config.yml")
  end

  # fxt advertisements on vcoooline.com
  def fxt
    @supplier_apply = SupplierApply.new(apply_type: SupplierApply::AGENCY)
    @app_config = YAML.load_file("#{Rails.root}/config/app_config.yml")
  end

  def answer
    @interlocution_one_levels = InterlocutionOneLevel.all
    @interlocution_two_level = InterlocutionTwoLevel.where(id: params[:tid]).first || InterlocutionTwoLevel.first
  end

  def solution
    @html_class = "cases"
    @name = params[:name] ||= "category1"
    begin
      @cases = Case.show.send(@name)
    rescue
      @cases = Case.show.category1
    end
    respond_to do |format|
      format.html {}
      format.js do
        render json: {}
      end
    end
  end

  def new_index
    render layout: false
  end

  def spread
    @html_class = 'partner'
    @supplier_apply = SupplierApply.new(apply_type: SupplierApply::AGENCY)
    @app_config = YAML.load_file("#{Rails.root}/config/app_config.yml")
  end

  def helpers
    @assistants = Assistant.enabled.helpers.order('sort ASC')
    render "home/life_assistant", layout: 'application'
  end

  def games
    @assistants = Assistant.enabled.games.order('sort ASC')
    render "home/life_assistant", layout: 'application'
  end

  def show_introduce
    ret = params[:ret].to_i
    current_user.update_show_introduce ret
    redirect_to root_url
  end

  def help_menus
    # 假帐号登录
    session[:pc_supplier_id] = TEST_USER_ID if session[:pc_supplier_id].blank?
    @help_menus = HelpMenu.winwemedia.order(:sort)
    render layout: 'application'
  end

  def uzhe_help
    session[:pc_supplier_id] = TEST_USER_ID if session[:pc_supplier_id].blank?
    @help_menus = HelpMenu.youzhe.order(:sort)
    # render 'help_menus', layout: 'application'
    render layout: false
  end

  def help_post
    # 假帐号登录
    session[:pc_supplier_id] = TEST_USER_ID if session[:pc_supplier_id].blank?
    @help_menu = HelpMenu.where(id: params[:id].to_i).first

    return redirect_to root_url, alert: '页面不存在' unless @help_menu

    if @help_menu.winwemedia?
      @uzhe = false
      render layout: 'application'
    else
      @uzhe = true
      render 'uzhe_post', layout: false
    end
  end

  # TODO
  def dev_logs
    redirect_to site_dev_logs_url
  end

  def uzhe_logs
    redirect_to oa_site_dev_logs_url
  end

  def show_dev_log
    return redirect_to root_url, alert: '页面不存在' if params[:id].to_i == 0

    redirect_to site_dev_log_url(id: params[:id].to_i)
  end

  def verify_code
    image = VerifyCode.new(4)
    session[:image_code] = image.code
    send_data image.code_image, :type => 'image/jpeg', :disposition => 'inline'
  end

  def validate_image_code
    if session[:image_code] != params[:image_code]
      return render json: {code: -1, message: "验证码错误!", num: 3, status: 0}
    else
      return render json: {code: 1}
    end
  end

  def not_found
    render "404_#{detect_browser}", layout: "mobile" != detect_browser, :status => 404
  end

  def error
    render "500_#{detect_browser}", layout: "mobile" != detect_browser
  end

  private

  MOBILE_BROWSERS = ["playbook", "windows phone", "android", "ipod", "iphone", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    agent = request.user_agent.to_s.downcase

    MOBILE_BROWSERS.each do |m|
      return "mobile" if agent.match(m)
    end
    return "desktop"
  end

  def print_f(float)
    num = format("%0.1f", float)
    b = 7 - num.length #最大5位数
    b = 0 if b < 0
    ret = " " * b + num.to_s
    ret
  end

end
