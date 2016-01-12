class Mobile::BaseController < ActionController::Base
  include ErrorHandler, DetectUserAgent

  helper_method :judge_andriod_version, :wx_browser?

  before_filter :redirect_to_non_openid_url, :load_site, :load_data, :load_user_data, except: [:notice]

  before_filter :auth, if: -> { @wx_mp_user.try(:manual?) }
  before_filter :authorize, if: -> { @wx_mp_user.try(:plugin?) }
  before_filter :fetch_wx_user_info

  def check_browser_type
    @is_micro_messenger_browser = wx_browser?
  end

  def load_data
    session[:site_id] = params[:site_id] if params[:site_id].present?

    # TODO 只投票有用，需要去掉
    session[:activity_id] = params[:vote_id] if params[:vote_id].present?
    session[:activity_id] = params[:aid] if params[:aid].present?
    session[:activity_id] = params[:activity_id] if params[:activity_id].present?
    session[:activity_notice_id] = params[:anid] if params[:anid].present?

    @site = Site.find(session[:site_id].to_i)

    return render text: '该公众号服务已到期，暂不提供服务！' if @site.froze?

    @wx_mp_user = @site.wx_mp_user
    require_wx_mp_user

    @account_footer = AccountFooter.default_footer
  rescue => error
    logger.info "*********** mobile load_data error: #{error.message} > #{error.backtrace}"
    # render :text => "请求页面参数不正确"
    return redirect_to mobile_notice_url(msg: '请求参数不正确')
  end

  def notice
  end

  def load_vip_user
    @vip_user = @site.vip_users.visible.where(user_id: session[:user_id]).first
  end

end
