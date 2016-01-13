class App::WhouseController < App::BaseController
  layout 'app/whouse'
  before_filter :find_wx_user

  def index
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house
          @cover_house_pictures = @house.house_pictures.where(is_cover: true).order("is_cover desc")
          @house_layouts = @house.house_layouts.normal
          @house_comments = @house.house_comments.where("status > ?", -1).order("created_at desc").limit(2)
          @house_expert_comments = @house.house_expert_comments.normal.order("created_at desc").limit(2)
        end
      end
    end
  end
    
  def layout
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house and params[:hlid].present?
          @cover_house_pictures = @house.house_pictures.where(is_cover: true).order("is_cover desc")
          @house_layout = @house.house_layouts.normal.find(params[:hlid])
        end
      end
    end
  end

  def intro
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house
          @cover_house_pictures = @house.house_pictures.where(is_cover: true).order("is_cover desc")
        end
      end
    end
  end
    
  def impress
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house
          @cover_house_pictures = @house.house_pictures.where(is_cover: true)
          @total_house_comments = @house.house_comments.where("status > ?", -1).order("created_at desc")
          @search = @total_house_comments.search(params[:search])
          @house_comments = @search.page(params[:page])#.per(4)
        end
      end
    end
  end
    
  def comment
    if request.get?
      @activity = Activity.where(id: params[:aid]).first
      if @activity
        if @activity.activity_type.house?
          @house = @activity.activityable
          if @house
            @house_comment = @house.house_comments.new(supplier_id: session[:supplier_id], wx_mp_user_id:  session[:wx_mp_user_id], house_id: params[:hid])
          end
        end
      end
    else
      @activity = Activity.where(id: params[:aid]).first
      if @activity
        if @activity.activity_type.house?
          @house = @activity.activityable
          if @house
            respond_to do |format|
              if @house.house_comments.create!(supplier_id: @activity.supplier_id, wx_mp_user_id:  session[:wx_user_id], wx_user_id:  session[:wx_user_id], house_id: params[:hid], name: params[:name], mobile: params[:mobile], content: params[:content])
                format.json { render json: {status: 1}}
              else
                format.json { render json: {status: 0}}
              end
            end
          end
        end
      end
    end
  end

  def expert_comments
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house
          @house_expert_comments = @house.house_expert_comments.normal.order("created_at desc")
        end
      end
    end
  end

  def flashshow
    @activity = Activity.where(id: params[:aid]).first
    if @activity
      if @activity.activity_type.house?
        @house = @activity.activityable
        if @house
          @cover_house_pictures = @house.house_pictures.order("is_cover desc, house_layout_id desc")
        end
      end
    end
  end

  private
    def find_wx_user
      @wx_user = @wx_mp_user.wx_users.find session[:wx_user_id]
    end

end
