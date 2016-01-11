class Biz::PointTypesController < Biz::VipController

  def index
    @point_types = current_site.point_types.page(params[:page]).order("created_at desc")
  end

  def new
    @point_type  = current_site.point_types.new(category: PointType::CONSUME, amount: "", points: "", succ_checkin_days: "", succ_checkin_points: "", status: 1)
    @in_checkin  = current_site.point_types.checkin.exists?
    @in_register = current_site.point_types.register.exists?
    render :form, layout: 'application_pop'
  end

  def edit
    @point_type  = current_site.point_types.find(params[:id])
    @in_checkin  = current_site.point_types.where('id != ?', @point_type.id).checkin.exists?
    @in_register = current_site.point_types.where('id != ?', @point_type.id).register.exists?
    render :form, layout: 'application_pop'
  end

  def create
  	@point_type = current_site.point_types.new params[:point_type]
    if @point_type.save
      flash[:notice] = "保存成功"
      render inline: "<script>window.parent.location.reload();</script>"
    else
      render_with_alert :form, '保存失败', layout: 'application_pop'
    end
  end

  def update
    @point_type = current_site.point_types.find(params[:id])
    if @point_type.update_attributes(params[:point_type])
      flash[:notice] = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      render_with_alert :form, '保存失败', layout: 'application_pop'
    end
  end

  def edit_status
  	@point_type = current_site.point_types.find(params[:id])
  	if @point_type.update_attributes(status: @point_type.normal? ? 2 : 1)
  	  redirect_to :back, notice: '操作成功'
    else
      redirect_to :back, notice: '操作失败'
    end
  end
end