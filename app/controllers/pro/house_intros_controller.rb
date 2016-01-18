class Pro::HouseIntrosController < Pro::HousesBaseController
  def index
    @intro = current_site.house.intro || current_site.house.build_intro
    @activity = current_site.create_activity_for_house_intro
  end

  def activity
    @activity = current_site.create_activity_for_house_intro
  end

  def update_activity
    @activity = current_site.create_activity_for_house_intro
    if @activity.update_attributes(params[:activity])
      #redirect_to activity_house_intros_path, notice: '保存成功'
      redirect_to house_intros_path, notice: '保存成功'
    else
      # render :activity
      flash[:alert] = '保存失败'
      redirect_to house_intros_path(anchor: 'tab-1')
    end
  end

  def show
  end

  def create
    @intro = current_site.house.build_intro params[:house_intro]
    if @intro.save
      params[:house_intro_pictures].to_a.each do |k,v|
        @intro.pictures.create pic_key: v
      end
      flash[:notice] = "保存成功"
      redirect_to house_intros_path
    else
      return redirect_to :back , alert: '保存失败'
    end
  end

  def update
    @intro = current_site.house.intro
    if @intro.update_attributes(params[:house_intro])
      params[:house_intro_pictures].to_a.each do |k,v|
        @intro.pictures.create pic_key: v
      end
      flash[:notice] = "保存成功"
      redirect_to house_intros_path(anchor: 'tab-2')
    else
      return redirect_to :back , alert: '保存失败'
    end
  end

  def picture
    @intro = current_site.house.intro
    picture_id = params[:picture_id]
    @intro.pictures.where(picture_id).first.try :destroy
    render json: {result: "success"}
  end
end
