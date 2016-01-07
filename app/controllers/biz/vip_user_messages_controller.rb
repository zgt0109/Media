class Biz::VipUserMessagesController < Biz::VipController

  def index
    @search = current_user.vip_user_messages.latest.includes(:vip_user).search(params[:search])
    @messages = @search.page(params[:page])
  end

  def new
    load_vip_users
    if @vip_users.present?
      @message = current_user.vip_user_messages.build
      render layout: 'application_pop'
    else
      flash[:notice] = '没有会员，无法发送站内信'
      render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
    end
  end

  def create
    if params[:vip_user_message][:send_type].to_i == VipUserMessage::SEND_ALL
      VipUserMessage.send_to_all current_user, params[:vip_user_message]
    else
      @message = current_user.vip_user_messages.build params[:vip_user_message]
      load_vip_users and return render :new unless @message.save
    end
    flash[:notice] = "保存成功"
    render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
  end

  def show
    @message = current_user.vip_user_messages.find params[:id]
    render layout: 'application_pop'
  end

  def destroy
    @message = current_user.vip_user_messages.find params[:id]
    @message.destroy
    render js: "$('#message-row-#{@message.id}').remove();"
  end

  private

  def load_vip_users
    @vip_users = current_user.vip_users.visible.pluck(:name, :id)
  end

end