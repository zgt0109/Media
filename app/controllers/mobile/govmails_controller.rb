class Mobile::GovmailsController < Mobile::BaseController
  layout "mobile/gov"
  before_filter :set_activity

  def index
    @boxes = @activity.govmailboxes.normal
  end

  def my
    @mails = @wx_user.govmails.order("created_at DESC") rescue []
  end

  def new
    @mail = Govmail.new
  end

  def create
    @box  = @activity.govmailboxes.find(params[:box])
    @mail = @box.govmails.create(wx_user_id: session[:wx_user_id], body: params[:body])
    if @mail.persisted?
      params[:custom_field].to_a.each do |key, value|
        field = CustomField.find(key)
        field.custom_values.create(customized: @mail, value: value)
      end
      render json: { ajax_msg: { status: 1, url: mobile_govmails_path(activity_id: @activity.id) } }
    else
      render json: { ajax_msg: { status: 0 } }
    end
  end

  private

  def set_activity
    @activity    = @wx_mp_user.activities.govmail.show.first || @wx_mp_user.create_activity_for_govmail
    @share_title = @activity.name
    @share_desc  = @activity.summary
    @share_image = @activity.pic_url
  end
end
