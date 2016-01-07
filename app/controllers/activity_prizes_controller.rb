class ActivityPrizesController < ApplicationController
  DEFAULT_TITLES = %W(一等奖 二等奖 三等奖 四等奖 五等奖 六等奖)
  before_filter :require_activity
  before_filter :find_prize, only: [:show, :update, :destroy]

  def new
    title = (DEFAULT_TITLES - @activity.activity_prizes.pluck(:title)).first
    @prize = ActivityPrize.new(title: title, can_validate: true, activity_id: params[:activity_id])

    if without_probability?
      render :new_without_probability, layout: 'application_pop'  
    else
      render layout: 'application_pop'
    end
  end

  def show
    if without_probability?
      render :new_without_probability, layout: 'application_pop'
    else
      render :new, layout: 'application_pop'
    end
  end

  def probability
    if params[:prize_id].present?
      sum = @activity.activity_prizes.where("id != ?", params[:prize_id]).sum(:prize_rate)
    else
      sum = @activity.activity_prizes.sum(:prize_rate)
    end  
    status = (sum + params[:prize_rate].to_f) > 100 ? "false" : "true"
    num = (100 - sum) < 0 ? 0 : (100 - sum)
    render json: {status: status, num: num}
  end

  def create
    title = (DEFAULT_TITLES - @activity.activity_prizes.pluck(:title)).first
    if params[:activity_prize]
      @prize = @activity.activity_prizes.build params[:activity_prize]
      if @prize.save
        flash[:notice] = "保存成功"
        render inline: "<script>parent.location.reload();</script>"
      else
        redirect_to :back, alert: '保存失败', layout: 'application_pop'
      end
    elsif title &&  @activity.activity_prizes.build(title: title).save
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '最多只能添加六个奖项'
    end
  end

  def update
    if @prize.update_attributes(params[:activity_prize])
      flash[:notice] = "保存成功"
      render inline: "<script>parent.location.reload();</script>"
    else
      redirect_to :back, alert: '保存失败', layout: 'application_pop'
    end
  end

  def destroy
    @prize.destroy
    respond_to do |format|
      format.html {redirect_to :back}
    end
  end

  private

  def require_activity
    @activity = Activity.find params[:activity_id]
  end

  def find_prize
    @prize = ActivityPrize.find(params[:id])
  end

  def without_probability?
    @activity.micro_aid? 
  end
end
