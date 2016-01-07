class Biz::ReservationsController < ApplicationController
  before_filter :get_activity, only: [:new, :edit, :create, :update, :intro, :start, :stop, :orders, :fields, :remove_logo]
  def index
    all_activities = current_user.activities.reservations.show
    if params[:name].present?
      activities = all_activities.select do |activity|
        service = activity.extend.service.presence
        service && service.include?(params[:name])
      end
      @activities = all_activities.where(id: activities.collect(&:id))
    else
      @activities = all_activities
    end
    @activities= @activities.order("created_at DESC").page(params[:page]).per(20)
  end

  def new
    render layout: 'application_pop'
  end

  def orders
    @search = @activity.reservation_orders.search(params[:search])
    @orders = @search.order("created_at DESC").page(params[:page]).per(20)
    @fields = @activity.custom_fields.normal.visible.order(:position).limit(5)
  end

  def fields
    @search = @activity.custom_fields.normal.search(params[:search])
    @fields = @search.order(:position).page(params[:page]).per(20)
  end

  def edit
    render layout: 'application_pop'
  end

  def intro
    render layout: 'application_pop'
  end

  def stop
    redirect_to :back, notice: notice_for( @activity.stopped! )
  end

  def start
    redirect_to :back, notice: notice_for( @activity.setted! )
  end

  def remove_logo
    @activity.update_attributes(qiniu_logo_key: nil)
    redirect_to :back, notice: '操作成功'
  end

  def create
    @activity.attributes = params[:activity]
    @activity.extend.mobile = params[:mobile] if params[:mobile].present?
    @activity.extend.service = params[:service] if params[:service].present?
    if @activity.save
      flash[:notice] = '保存成功'
       render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      render_with_alert "edit", "保存失败，#{@activity.errors.full_messages.first}", layout: 'application_pop'
    end
  end

  def update
    @activity.attributes = params[:activity]  if params[:activity].present?
    @activity.extend.mobile = params[:mobile] if params[:mobile].present?
    @activity.extend.service = params[:service] if params[:service].present?
    if @activity.save
      flash[:notice] = '保存成功'
       render inline: '<script>parent.document.location = parent.document.location;</script>';
    else
      render_with_alert "edit", "保存失败，#{@activity.errors.full_messages.first}", layout: 'application_pop'
    end
  end

  private
    def get_activity
      @activity = current_user.activities.reservations.find_by_id(params[:id]) || current_user.activities.reservations.new
    end

    def notice_for( success )
      success ? "操作成功" : "操作失败"
    end

end
