class Mobile::WeddingsController < Mobile::BaseController
  layout 'mobile/wedding'

  before_filter :set_wedding
  #before_filter :require_wx_user, only: :create_guest

  def index
    @body_class = @wedding.template1? ? "index" : "index2"
  end

  def list
    @body_class = @wedding.template1? ? "list" : "list2"
    @wishes = @wedding.wishes.order("created_at desc")
  end

  def create_guest
    @wedding_guest.attributes = params[:wedding_guest]
    @wedding_guest.save!
    #redirect_to guest_app_weddings_path, notice:"提交成功"
    render :text => ''
  end

  def create_wish
    @wedding_wish.attributes =params[:wedding_wish]
    @wedding_wish.save!
    #render :text => ''
    render json: {username: @wedding_wish.username, content: @wedding_wish.content, created_at: @wedding_wish.created_at.strftime("%Y-%m-%d")}
  end

  private

  def set_wedding
    session[:wedding_id] = params[:wid] if params[:wid]
    #@wedding = @site.weddings.where(id: session[:wedding_id]).first
    @wedding = Wedding.find_by_id session[:wedding_id]
    if @wedding
      @activity = @wedding.activity
      session[:activity_id] = @activity.try(:id)

      @wedding_guest = @wedding.guests.build(user_id: session[:user_id])
      @wedding_wish = @wedding.wishes.build()
      @share_title = "#{@wedding.groom}和#{@wedding.bride}的婚礼请帖"
      @share_desc = "婚礼地点：" + @wedding.address.to_s.first(90)
    else
      return render_404
    end
  end
end
