module App
  class LeavingMessagesController < BaseController
    before_filter :block_non_wx_browser

    def index
      @activity = Activity.find(session[:activity_id])
      @share_image = @activity.qiniu_pic_url.present? ? @activity.qiniu_pic_url : @activity.default_pic_url
      supplier = @activity.supplier
      @replier = supplier.wx_mp_user.wx_users.find_by_id(session[:wx_user_id])

      @message = LeavingMessage.new(replier_id: session[:wx_user_id], replier_type: 'WxUser')

      @messages = supplier.leaving_messages.root
      @messages = @messages.audited if @activity.audited?
      @messages = @messages.order("created_at DESC").page(params[:page]).per(20)
      @template = LeavingMessageTemplate.where(supplier_id: supplier.id).first_or_create
      # return render :text => @template_id.inspect
      respond_to do |format|
        format.html
        format.js
      end
    end

    def create
      activity = Activity.find_by_id(session[:activity_id])
      if activity
        supplier = activity.supplier
        replier = supplier.wx_mp_user.wx_users.find_by_id(session[:wx_user_id])

        message = supplier.leaving_messages.create(params[:leaving_message])

        replier.update_attributes(nickname: message.nickname) if replier.present? && message.nickname.present?

        redirect_to app_leaving_messages_url
      else
        return render_404
      end
    end
  end
end
