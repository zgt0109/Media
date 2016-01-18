class Pro::HouseLayoutsController < Pro::HousesBaseController
  before_filter :find_house

  def index
    @activity = @house.activity
    @total_house_layouts = @house.house_layouts
    @search = @total_house_layouts.search(params[:search])
    @house_layouts = @search.page(params[:page])
    @house_picture  = HousePicture.new
    @house_layout = @total_house_layouts.where("id = ?", params[:id]).first || @total_house_layouts.new
    @house_pictures = @house.house_pictures.where(house_layout_id: nil)
    @house_picture_cover = @house_pictures.where(is_cover: true).first
  end

  def activity
    @activity = @house.activity
  end

  def panorama_360
    @house_layout = HouseLayout.find(params[:id])
    @house_layout.panorama_type_list = params[:panorama_type]
    @house_layout.save
    redirect_to house_layout_house_layout_panoramas_path(@house_layout)
  end

  def panorama_720
    @house_layout = HouseLayout.find(params[:id])
    @house_layout.panorama_type_list = params[:panorama_type]
    @house_layout.save
    redirect_to house_layout_house_layout_panoramas_path(@house_layout)
  end

  def update_activity
    @activity = @house.activity
    if @activity.update_attributes(params[:activity])
      redirect_to house_layouts_path, notice: '保存成功'
    else
      redirect_to house_layouts_path, alert: '保存失败'
    end
  end

  def show
    @house_layout = HouseLayout.find(params[:id])
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @house_layout }
    end
  end

  def new
    @house_layout = HouseLayout.new
    render layout: 'application_pop'
  end

  def edit
    @house_layout = HouseLayout.find(params[:id])
    render layout: 'application_pop'
  end

  def create
    @house_layout = HouseLayout.new(params[:house_layout].merge(orientation: '朝南', floor_height: 1, price: 1))
    if @house_layout.save
      flash[:notice] = "保存成功"
      #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      render inline: "<script>parent.location.reload();</script>"
    else
      return  redirect_to :back, alert: '保存失败'
    end
  end

  def update
    @house_layout = HouseLayout.find(params[:id])
    if @house_layout.update_attributes(params[:house_layout])
      flash[:notice] = "保存成功"
      #render inline: "<script>window.parent.document.getElementById('pop-name').style.display='none';window.parent.location.reload();</script>"
      render inline: "<script>parent.location.reload();</script>"
    else
      return  redirect_to :back, alert: '保存失败'
    end
  end

  def destroy
    @house_layout = HouseLayout.find(params[:id])
    @house_layout.destroy

    respond_to do |format|
      format.html { redirect_to house_layouts_path(anchor: 'tab-2'), notice: '删除成功' }
    end
  end

  private
    def find_house
      @house = current_site.house
    end
end
