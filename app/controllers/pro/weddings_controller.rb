class Pro::WeddingsController < Pro::WeddingsBaseController
  before_filter :render_index, :except => [:index]

  def index
    conn = Wedding.get_conditions params
    @weddings = current_user.weddings.includes(:activity).where(conn).order("weddings.created_at desc").page(params[:page])
  end

  def edit_template
    render layout: 'application_pop'
  end

  def update_template
    @wedding.attributes = params[:wedding]
    if @wedding.save
      flash[:notice] = '模板选择成功'
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      flash[:alert] = '模板选择失败'
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    end
  end

  def edit
    @activity = @wedding.activity || current_user.wx_mp_user.create_activity_for_wedding
  end

  def new
    @wedding ||= current_user.weddings.new
    @activity = current_user.wx_mp_user.create_activity_for_wedding
  end

  def cities
    @cities = City.where(province_id: params[:province_id]).pluck(:name, :id)
  end

  def create
    @activity = current_user.wx_mp_user.create_activity_for_wedding
    if @activity.update_attributes params[:activity]
      attrs    = { wx_mp_user: current_user.wx_mp_user, activity: @activity }
      wedding = current_user.weddings.new params[:wedding].merge(attrs)
      if wedding.save
        flash[:notice] = '保存成功'
      else
        flash[:alert] = '保存异常'
      end
    else
      flash[:alert] = '保存异常，请检查关键词是否重复'
    end
    redirect_to weddings_path
  end

  def create_old
    @activity = current_user.wx_mp_user.create_activity_for_wedding
    @activity.update_attributes params[:wedding].delete(:activity_attributes)
    attrs    = { wx_mp_user: current_user.wx_mp_user, activity: @activity }
    @wedding  = current_user.weddings.build params[:wedding].merge(attrs)
    if @wedding.save
      flash[:notice] = '保存成功'
      render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      render :action => :new, layout: 'application_pop'
    end
  end

  def story
    @wedding = Wedding.find(params[:id])
  rescue
    redirect_to :back, :alert => "没有婚礼信息"
  end

  def update_story
    @wedding  = Wedding.find(params[:id])
    @wedding.attributes = params[:wedding]
    return render :story unless @wedding.story_valid?
    if @wedding.save
      redirect_to story_wedding_path(@wedding), notice: '保存成功'
    else
      render :story
    end
  end

  def show
    render_index
  end

  def update
    @activity = @wedding.activity || current_user.wx_mp_user.create_activity_for_wedding
    if @activity.update_attributes(params[:activity]) and @wedding.update_attributes(params[:wedding])
      flash[:notice] = '修改成功'
      redirect_to weddings_path
    else
      @activity = @wedding.activity
      flash[:alert] = '修改失败'
      redirect_to edit_wedding_path(@wedding)
    end
  end

  def set_seats_status
    wedding = current_user.wedding
    if wedding.update_column(:seats_status, wedding.seats_status * (-1))
      render json: { success: 1}
    else
      render json: { error: 1 }
    end
  end

  def destroy
    @wedding.destroy
    flash[:notice] = "删除成功"
    redirect_to weddings_path
  end

  private
  def render_index
    @wedding = Wedding.find_by_id(params[:id]) || Wedding.new(activity: Activity.new)
    @provinces           = Province.pluck(:name, :id)
    province_id          = @wedding.new_record? ? 9 : @wedding.province_id
    @cities              = City.where(province_id: province_id).pluck(:name, :id)
  end

  def validate_story_content
    return unless params[:wedding].key?(:story_title)
  end

end
