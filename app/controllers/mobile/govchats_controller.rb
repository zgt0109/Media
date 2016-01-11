class Mobile::GovchatsController < Mobile::BaseController
  layout 'mobile/gov'
  before_filter :set_activity

  def index

  end

  def my
    @chats = @wx_user.govchats.order("created_at DESC") rescue []
  end

  def new
    @chat = @activity.govchats.new
  end

  def create
    @chat = @activity.govchats.create(chat_type: params[:chat_type], user_id: session[:user_id], body: params[:body])
    if @chat.persisted?
      params[:custom_field].to_a.each do |key, value|
        field = CustomField.find(key)
        field.custom_values.create(customized: @chat, value: value)
      end
      render json: { ajax_msg: { status: 1, url: mobile_govchats_path(activity_id: @activity.id) } }
    else
      render json: { ajax_msg: { status: 0 } }
    end
  end

  private

  def set_activity
    @activity    = @site.activities.govchat.show.first || @site.create_activity_for_govchat
    @share_title = @activity.name
    @share_desc  = @activity.summary
    @share_image = @activity.pic_url
  end
end
