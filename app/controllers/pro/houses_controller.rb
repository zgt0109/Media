class Pro::HousesController < Pro::HousesBaseController
  skip_before_filter :require_house, except: [:edit, :update, :destroy]

  def index
    @house = current_site.house || House.create!(site_id: current_site.id, name: '微房产')
    @house.activity = Activity.create!(site_id: current_site.id, activity_type_id: ActivityType::HOUSE, activityable: @house, status: 1,ready_at: Time.now, start_at: Time.now, end_at: Time.now+100.years, name: '微房产', keyword: '微房产' ) unless @house.activity
    # @activity = @house.activity
    redirect_to house_intros_path
  end

  def update
    @house = current_site.house
    return redirect_to :back, notice: '找不到楼盘信息' unless @house.id == params[:id].to_i
    if @house.update_attributes(params[:house])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@house.errors.full_messages.join('，')}"
    end
  end
end
