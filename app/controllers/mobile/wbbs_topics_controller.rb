class Mobile::WbbsTopicsController < Mobile::BaseController
  layout 'app'
  before_filter :block_non_wx_browser, :set_class_name, :find_wbbs_community, :get_wx_mp_user
  before_filter :find_wbbs_topic, only: [ :show, :vote_up, :create_reply, :report, :load_replies, :display_photo ]

  def index
    if params[:receiver_id]
      @receiver = WxUser.find_by_id(params[:receiver_id])
      @wbbs_topics = @wbbs_community.wbbs_topics.where(receiver_type: 'WxUser', receiver_id: params[:receiver_id], status: [2,3]).recent
    else
      #空间
      @wbbs_topics = @wbbs_community.wbbs_topics.sticked.recent.normal
    end

    #我的话题
    @wbbs_topics = @wbbs_topics.where(poster_type: 'WxUser', poster_id: @wx_user.id) if params.key?( :my )
    #某个用户的话题
    @wbbs_topics = @wbbs_topics.where(poster_type: 'WxUser', poster_id: params[:poster_id]) if params.key?( :poster_id )

    @wbbs_topics = @wbbs_topics.where("id < ?", params[:id]) if params[:id]
    top_ids = params[:top_ids].split(',') rescue []
    if top_ids.present?
      top_ids_string = top_ids.join(',')
      @wbbs_topics = @wbbs_topics.where("id NOT IN (?)", top_ids_string)
    end
    @wbbs_topics = @wbbs_topics.page(params[:page]).per(10)

    @share_image = @wbbs_community.logo_url

    load_unread_notifications_count
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    load_unread_notifications_count
    @share_image = @wbbs_community.logo_url
  end

  def display_photo
    @body_class = 'body-photo'
    @not_show_mark = true
  end

  def new
    @wbbs_topic = WbbsTopic.new
    @share_image = @wbbs_community.logo_url
  end

  def create
    @wbbs_topic = @wbbs_community.create_wbbs_topics( params[:wbbs_topic][:content], @wx_user )
    if @wbbs_topic.persisted?
      @wbbs_topic.update_attributes(status: params[:wbbs_topic][:status]) if params[:wbbs_topic][:status].present?
      @wbbs_topic.update_attributes(receiver_id: params[:wbbs_topic][:receiver_id].to_i, receiver_type: 'WxUser') if params[:wbbs_topic][:receiver_id].present?
      image_keys = params[:image_keys].split(',').compact.flatten rescue []
      image_keys.each do |sn|
        @wbbs_topic.qiniu_pictures.where(sn: sn).first_or_create if sn.present?
      end
      if params[:wbbs_topic][:receiver_id].present?
        if params[:wbbs_topic][:status] == '3'
          render inline: "<script>alert('私信成功'); location.href = '#{mobile_wbbs_topics_path(@supplier, receiver_id: params[:wbbs_topic][:receiver_id])}';</script>"
        else
          render inline: "<script>alert('留言成功'); location.href = '#{mobile_wbbs_topics_path(@supplier, receiver_id: params[:wbbs_topic][:receiver_id])}';</script>"
        end
      else
        render inline: "<script>alert('发帖成功'); location.href = '#{mobile_wbbs_topics_path(@supplier)}';</script>"
      end
    else
      render inline: "<script>alert('发送失败，#{@wbbs_topic.errors.full_messages.first}');</script>"
    end
  end

  def vote_up
    @wbbs_topic.vote_up!( @wx_user )
    render nothing: true
  end

  def set_user_info
    @wx_user.update_column(:nickname, params[:nickname]) if params[:nickname].present?
    headimgurl = qiniu_image_url(params[:headimgurl]) if params[:headimgurl].present?
    @wx_user.update_column(:headimgurl, headimgurl) if headimgurl.present?
    render js: "location.reload()"
  end

  def report
    @wbbs_topic.report!( @wx_user )
    render js: "alert('举报成功');location.reload();"
  end

  def create_reply
    wbbs_reply = @wbbs_topic.create_reply( params[:wbbs_reply], @wx_user )
    if wbbs_reply.persisted?
      render js: "alert('回复成功'); location.reload();"
    else
      render js: "alert('回复失败，#{@wbbs_reply.errors.full_messages.first}'); "
    end
  end

  def load_replies
    @wbbs_replies = @wbbs_topic.wbbs_replies.where("id < ?", params[:reply_id]).recent(WbbsReply::PAGE_SIZE)
    @wbbs_replies_count = @wbbs_topic.wbbs_replies.where("id < ?", params[:reply_id]).count
  end

  def wbbs_notifications
    @wbbs_notifications = @wx_user.wbbs_notifications.unread.recent rescue WbbsNotification.none
    @wbbs_notifications = @wbbs_notifications.where("id < ?", params[:id]) if params[:id]
    @wbbs_notifications = @wbbs_notifications.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  def read_notification
    notification = WbbsNotification.find params[:id]
    notification.update_attributes(status: WbbsNotification::READ)
    render js: 'void(0);'
  end

  private
    def get_wx_mp_user
      @wx_mp_user =  WxMpUser.find_by_id(session[:wx_mp_user_id])
    end

    def find_wbbs_community
      @activity =  Activity.wbbs_community.find_by_id(params[:activity_id]) || Activity.wbbs_community.find_by_id(session[:activity_id])
      @wbbs_community = @activity.try(:activityable)
      return render_404 unless @wbbs_community
      if params[:noshare] == 'noshare'
         session[:noshare_supplier_id] = session[:supplier_id]
      end
      @noshare = (session[:supplier_id] == session[:noshare_supplier_id])
    end

    def set_class_name
      @html_class, @main_class, @main_id = 'html', 'stage', 'stage'
    end

    def find_wbbs_topic
      @wbbs_topic = @wbbs_community.wbbs_topics.find params[:id]
    end

    def load_unread_notifications_count
      @notifications_count = @wx_user ? @wx_user.wbbs_notifications.unread.count : 0
    end
end
