class Wx::MessagesController <  ApplicationController

  before_filter do
    @partialLeftNav = "/layouts/partialLeftWeixin"
  end

  def send_message
    options = {:media_type=>"text",:is_to_all=>true ,:content=>params[:text_message]}
    notice=  current_site.wx_mp_user.message_mass_send_all(options)["msg_id"].nil? ? '保存失败消息发送超出上限' : '保存成功'

    respond_to do |format|
      format.html { redirect_to :back, notice: notice }
    end
  end
end
