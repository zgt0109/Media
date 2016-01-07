class Pro::BrochePhotosController < Pro::HousesBaseController

  before_filter :find_broche
  before_filter :find_broche_photo, only: [:edit, :update, :destroy]

  def index
    @broche_photos = @broche.broche_photos.order("sort asc")
  end

  def new
    if @broche.broche_photos.count >= 5
      flash[:alert] = "最多只能上传5张图片"
      return render inline: '<script>parent.location.reload();</script>';
    end
    @broche_photo = @broche.broche_photos.new(supplier_id: current_user.id, wx_mp_user_id: current_user.wx_mp_user.id, sort: @broche.sort_value)
    render layout: "application_pop"
  end

  def create
    @broche_photo = @broche.broche_photos.new(params[:broche_photo])
    if @broche_photo.save
      flash[:notice] = "新增成功"
    else
      flash[:alert] = "新增失败"
    end
    render inline: '<script>parent.location.reload();</script>';
  end

  def edit
    render layout: "application_pop"
  end

  def update
    @broche_photo.attributes = params[:broche_photo]
    if @broche_photo.save
      flash[:notice] = "修改成功"
    else
      flash[:alert] = "修改失败"
    end
    render inline: '<script>parent.location.reload();</script>';
  end

  def destroy
    @broche_photo.destroy
    render text: ''
   # render js: "$('#photo_#{@broche_photo.id}'.remove();"
  end

  private

  def find_broche
    @broche = current_user.broche
    return render text: "未初始化微楼书" unless @broche
  end

  def find_broche_photo
    @broche_photo = @broche.broche_photos.where(id: params[:id]).first
    unless @broche_photo
      flash[:notice] = "数据不存在"
      render inline: '<script>parent.location.reload();</script>';
    end
  end

end
