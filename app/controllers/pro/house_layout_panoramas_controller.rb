class Pro::HouseLayoutPanoramasController < Pro::HousesBaseController
  before_filter :find_house

  def index
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panoramas = @house_layout.panoramas.order("id desc")
    @standalone_panorama = @house_layout.standalone_panoramas.first
  end

  def show
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.find params[:id] 
  end

  def new
    @house_layout = HouseLayout.find params[:house_layout_id]
    #@panorama = @house_layout.panoramas.where("tile0 is null or tile1 is null or tile2 is null or tile3 is null or tile4 is null or tile5 is null").last || @house_layout.panoramas.new
    @panorama = @house_layout.panoramas.new
  end

  def create
    @house_layout = HouseLayout.find params[:house_layout_id]
    #last = @house_layout.panoramas.where("tile0 is null or tile1 is null or tile2 is null or tile3 is null or tile4 is null or tile5 is null or name is null").last
    @panorama = @house_layout.panoramas.find_by_id(params[:panorama_id]) || @house_layout.panoramas.where("name is null").last || @house_layout.panoramas.new
    if params[:file_name] =~ /0.jpg/
      @panorama.tile0 = params[:pic_key]
    elsif params[:file_name] =~ /1.jpg/
      @panorama.tile1 = params[:pic_key]
    elsif params[:file_name] =~ /2.jpg/
      @panorama.tile2 = params[:pic_key]
    elsif params[:file_name] =~ /3.jpg/
      @panorama.tile3 = params[:pic_key]
    elsif params[:file_name] =~ /4.jpg/
      @panorama.tile4 = params[:pic_key]
    elsif params[:file_name] =~ /5.jpg/
      @panorama.tile5 = params[:pic_key]
    else
    end
    @panorama.name = params[:panorama_name] if params[:panorama_name].present?

    respond_to do |format|
      if @panorama.save
        flash[:notice] ||= "全景图已保存" 
        format.html {redirect_to edit_house_layout_house_layout_panorama_path(@house_layout,@panorama)}
        format.json {render json: {message: "save ok",code: 0}} 
      else
        format.html {redirect_to :back, alert: "全景图保存出错，确保输入全景照片和名称"} 
        format.json {render json: {message: "save failed",code: -1}} 
      end
    end
  end

  def create_old
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.new params[:house_layout_panorama].to_h.keep_if{|k,v| ['name','tile0','tile1','tile2','tile3','tile4','tile5'].include?(k)}
    if @panorama.save
      redirect_to edit_house_layout_house_layout_panorama_path(@house_layout,@panorama), notice: "全景图保存成功"
    else
      redirect_to :back, alert: "全景图保存出错，确保输入全景照片和名称"
    end
  end

  def edit
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.find params[:id] 
  end

  def update
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.find params[:id] 
    if @panorama.update_attributes 
      redirect_to edit_house_layout_house_layout_panorama_path(@house_layout,@panorama), notice: "全景图保存成功"
    else
      redirect_to :back, alert: "全景图保存出错"
    end
  end

  def update_old
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.find params[:id] 
    if @panorama.update_attributes params[:house_layout_panorama].to_h.keep_if{|k,v| ['name','tile0','tile1','tile2','tile3','tile4','tile5'].include?(k)}
      redirect_to edit_house_layout_house_layout_panorama_path(@house_layout,@panorama), notice: "全景图保存成功"
    else
      redirect_to :back, alert: "全景图保存出错"
    end
  end

  def destroy
    @house_layout = HouseLayout.find params[:house_layout_id]
    @panorama = @house_layout.panoramas.find params[:id] 
    @panorama.destroy
    redirect_to house_layout_house_layout_panoramas_path(@house_layout)
  end

  private
    def find_house
      @house = current_site.house
    end
end
