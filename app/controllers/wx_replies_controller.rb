class WxRepliesController < ApplicationController

  def new
    @wx_reply = WxReply.new
  end

  def create
    @wx_reply = WxReply.new(params[:wx_reply])

    if @wx_reply.save
      if @wx_reply.click_event? 
        if current_user.can_show_introduce? && current_user.task3?
          current_user.update_attributes(show_introduce: 4)
          redirect_to welcome_wx_mp_users_url(task: Time.now.to_i), notice: '保存成功'
        else
          redirect_to welcome_wx_mp_users_url, notice: '保存成功'
        end
      else
        redirect_to :back, notice: '保存成功'
      end
    else
      redirect_to :back, alert: "保存成功:#{@wx_reply.errors.full_messages}"
    end
  rescue => error
    redirect_to :back, alert: "保存成功:#{error}"
  end

  def update
    @wx_reply = WxReply.find(params[:id])
    if @wx_reply.update_attributes(params[:wx_reply])
      if @wx_reply.click_event? 
        if current_user.can_show_introduce? && current_user.task3?
          current_user.update_attributes(show_introduce: 4)
          redirect_to welcome_wx_mp_users_url(task: Time.now.to_i), notice: '保存成功'
        else
          redirect_to welcome_wx_mp_users_url, notice: '保存成功'
        end
      else
        redirect_to :back, notice: '保存成功'
      end
    else
      redirect_to :back, alert: '保存失败'
    end
  end

end
