class Pro::HousesController < Pro::HousesBaseController
  skip_before_filter :require_house, except: [:edit, :update, :destroy]

  def index
    @wx_mp_user = current_user.wx_mp_user
    return redirect_to wx_mp_users_path, alert: '请先添加微信公共帐号' unless @wx_mp_user

    @house = current_user.house || House.create!(supplier_id: current_user.id, wx_mp_user_id: @wx_mp_user.id, name: '微房产')
    @house.activity = Activity.create!(supplier_id: current_user.id, wx_mp_user_id: @wx_mp_user.id, activity_type_id: ActivityType::HOUSE, activityable: @house, status: 1,ready_at: Time.now, start_at: Time.now, end_at: Time.now+100.years, name: '微房产', keyword: '微房产' ) unless @house.activity
    # @activity = @house.activity
    redirect_to house_intros_path
  end

  def update
    @house = current_user.house
    return redirect_to :back, notice: '找不到楼盘信息' unless @house.id == params[:id].to_i
    if @house.update_attributes(params[:house])
      redirect_to :back, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败：#{@house.errors.full_messages.join('，')}"
    end
  end
end
