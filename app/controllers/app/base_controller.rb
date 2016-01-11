class App::BaseController < ActionController::Base
  include ErrorHandler, DetectUserAgent

  helper_method :judge_andriod_version, :wx_browser?

  before_filter :redirect_to_non_openid_url, :load_site, :load_data, :load_user_data

  before_filter :auth, if: -> { @wx_mp_user.try(:manual?) }
  before_filter :authorize, if: -> { @wx_mp_user.try(:plugin?) }
  before_filter :fetch_wx_user_info

  layout 'app'

  def load_data
    # if params[:wxmuid].present? && params[:wxmuid] != session[:wx_mp_user_id]
    #   session.clear
    #   session[:wx_mp_user_id] = params[:wxmuid]
    # end
    session[:wx_mp_user_id] = params[:wxmuid].to_i if params[:wxmuid].present?

    session[:activity_id] = params[:activity_id] if params[:activity_id]
    session[:activity_id] = params[:aid] if params[:aid]
    session[:activity_notice_id] = params[:anid] if params[:anid]

    @wx_mp_user = WxMpUser.find(session[:wx_mp_user_id].to_i)
    @supplier = @wx_mp_user.supplier
    return render text: '该公众号服务已到期，暂不提供服务！' if @supplier.froze?

    session[:supplier_id] = @supplier.try(:id)
    @account_footer = AccountFooter.find_by_id(@supplier.try(:account_footer_id)) || AccountFooter.default_footer
  rescue => error
    logger.info "*********** app load_data error: #{error.message} > #{error.backtrace}"
    # render :text => "请求页面参数不正确"
    return redirect_to mobile_notice_url(msg: '请求参数不正确')
  end

  def app_params
    hash = {}
    hash[:wxmuid] = session[:wx_mp_user_id]      if session[:wx_mp_user_id]
    hash[:aid]    = session[:activity_id]        if session[:activity_id]
    hash[:anid]   = session[:activity_notice_id] if session[:activity_notice_id]
    hash
  end

end
