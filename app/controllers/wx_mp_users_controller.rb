class WxMpUsersController < ApplicationController
  before_filter :set_wx_mp_user, except: [:new, :create]

  def index
  end

  def welcome
    @wx_reply = @wx_mp_user.first_follow_reply || @wx_mp_user.wx_replies.new(event_type: WxReply::CLICK_EVENT)
    @wx_reply.reply_type = 2 if current_user.can_show_introduce? && current_user.task3?
  end

  def reply
    @wx_reply = @wx_mp_user.text_reply || @wx_mp_user.wx_replies.new(event_type: WxReply::TEXT_EVENT)
  end

  def new
    @wx_mp_user = WxMpUser.new
  end

  def create
    @wx_mp_user = WxMpUser.new(params[:wx_mp_user])

    respond_to do |format|
      if @wx_mp_user.save
        format.html { redirect_to wx_mp_users_url(step: 2) }
        format.json { render action: 'show', status: :created, location: @wx_mp_user }
      else
        format.html { redirect_to :back, alert: "添加失败:#{@wx_mp_user.errors.full_messages}" }
        format.json { render json: @wx_mp_user.errors, status: :unprocessable_entity }
      end
    end
  rescue => error
    redirect_to :back, alert: "添加失败:#{error}"
  end

  def update
    respond_to do |format|
      if @wx_mp_user.update_attributes(params[:wx_mp_user])
        @wx_mp_user.auth!(1) if params[:wx_mp_user].present? && params[:wx_mp_user][:app_secret].present?
        format.html {
          if params[:step]
            redirect_to(wx_mp_users_url(step: params[:step]))
          elsif params[:type] == 'qrcode'
            flash[:notice] = '操作成功'
            render inline: "<script>window.parent.location.href = '#{platforms_url}';</script>"
          else
            redirect_to(:back, notice: '保存成功')
          end
        }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, alert: '保存失败' }
        format.json { render json: @wx_mp_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def qrcode
    render layout: 'application_pop'
  end

  def oauth
  end

  def open_oauth
    respond_to do |format|
      # if !@wx_mp_user.auth_service?
        # format.js { render js: "showTip('warning', '只有认证服务号才权限使用此功能');" }
      if @wx_mp_user.open_oauth!
        format.js { render js: "$('.info').html('');$('.btn-pluin').attr('href', '#{close_oauth_wx_mp_user_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  def close_oauth
    respond_to do |format|
      # if !@wx_mp_user.auth_service?
        # format.js { render js: "showTip('warning', '只有认证服务号才权限使用此功能');" }
      if @wx_mp_user.close_oauth!
        format.js { render js: "$('.btn-pluin').attr('href', '#{open_oauth_wx_mp_user_path}');showTip('success', '操作成功');" }
      else
        format.js { render js: "showTip('warning', '操作失败');" }
      end
    end
  end

  def auth
    if @wx_mp_user.auth!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def enable
    if @wx_mp_user.enable!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def disable
    if @wx_mp_user.disable!
      redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  private

  def set_wx_mp_user
    @wx_mp_user = current_user.wx_mp_user
    return redirect_to platforms_url unless @wx_mp_user
  end

end
