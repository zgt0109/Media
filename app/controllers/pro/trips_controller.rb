class Pro::TripsController < Pro::TripBaseController
  layout "pro/trip"
  before_filter :get_wx_mp_user, :set_seo, :require_industry
  before_filter :exist_trip, only: [:ads, :ticket, :order]

  def index
    @current_titles << '旅游服务'
    @trip = current_site.trip || Trip.new(site_id: current_site.id, name: "微旅游")
    @trip.activity = Activity.new(site_id: current_site.id, activity_type_id: ActivityType::TRIP, activityable: @trip, status: 1 ) unless @trip.activity

    @trip_ads = @trip.trip_ads.order(:sort)
  end

  def create
    @trip = current_site.build_trip(params[:trip])
    @trip.activity.activityable = @trip
    @trip.activity.site = current_site

    if @trip.activity.save && @trip.save_trip_act(params)
      redirect_to trips_path, notice: '保存成功'
    else
      render_with_alert :index, "保存失败：#{@trip.errors.full_messages.join('，')}"
    end
  end

  def update
    @trip = current_site.trip

    if @trip.update_attributes(params[:trip])
      @trip.save_trip_act(params)
      redirect_to trips_path, notice: '保存成功'
    else
      render_with_alert :index, "保存失败：#{@trip.errors.full_messages.join('，')}"
    end
  end

  def ads
    @current_titles << '轮播图片'
    @trip = current_site.trip || Trip.new(site_id: current_site.id, name: "微旅游")
    @trip.activity = Activity.new(site_id: current_site.id, activity_type_id: ActivityType::TRIP, activityable: @trip, status: 1 ) unless @trip.activity

    @trip_ads = current_site.trip.trip_ads.order(:sort) || []
  end

  def ad_add
    sorts = current_site.trip.trip_ads.pluck(:sort)
    trip_ad_params = HashWithIndifferentAccess.new(params[:trip_ad] || {})

    if sorts.length < 5
      ad = TripAd.new(site_id: current_site.id, trip_id: current_site.trip.id)
      ad.title = trip_ad_params[:title]
      ad.pic_key = trip_ad_params[:pic_key]
      ad.sort = sorts.max || 0
      ad.save
      flash = {notice: "上传成功！"}
    else
      flash = {alert: "最多上传五张轮播图片"}
    end

    redirect_to trips_path(anchor: "tab-2"), flash
  end

  def up_ad_title
    trip_ad_params = HashWithIndifferentAccess.new(params[:trip_ad] || {})
    ad = current_site.trip.trip_ads.find(trip_ad_params[:id])
    ad.title = trip_ad_params[:title]
    ad.save
    render json: {title: trip_ad_params[:title]}
  end

  def del_ad
    ad = current_site.trip.trip_ads.find(params[:id])
    ad.destroy
    redirect_to trips_path(anchor: "tab-2")
  end

  def ticket
    @category = current_site.trip_ticket_categories.where(id: params[:trip_ticket_category_id]).first
    @current_titles << '门票管理'
    @search = current_site.trip.trip_tickets.visible.categorized(@category).latest.search(params[:search])
    @trip_tickets = @search.page(params[:page])
  end

  def new_ticket
    @trip_ticket = current_site.trip.trip_tickets.new
  end

  def save_ticket
    @current_titles << '门票管理'
    ticket_id = params[:ticket_id].presence
    @trip_ticket = ticket_id ? current_site.trip.trip_tickets.find(ticket_id) : current_site.trip.trip_tickets.new
    @trip_ticket.site = current_site
    @trip_ticket.attributes = params[:trip_ticket]
    if @trip_ticket.save
      redirect_to ticket_trips_path, notice: '保存成功'
    else
      redirect_to :back, alert: "保存失败，#{@trip_ticket.errors.full_messages.join('，')}"
    end
  end

  def destroy_ticket
    @trip_ticket = current_site.trip.trip_tickets.find(params[:ticket_id])
    @trip_ticket.deleted!
    redirect_to ticket_trips_path, notice: '操作成功'
  end

  def show_ticket
    @trip_ticket = current_site.trip.trip_tickets.find(params[:id])
  end

  def ticket_status
    trip_ticket = current_site.trip.trip_tickets.find(params[:id])
    trip_ticket.update_attributes(status: trip_ticket.status == 1 ? -1 : 1)
    redirect_to ticket_trips_path
  end

  def order
    @current_titles << '预约管理'
    search_params = params[:search]
    @search = current_site.trip.trip_orders.order('created_at desc').search(search_params)
    @trip_orders = @search.page(params[:page])

    if params[:search].present?
      @created_at_range = %Q(#{search_params[:created_at_gte].try(:to_date)} - #{search_params[:created_at_lte].try(:to_date)}) if search_params[:created_at_gte].present? and search_params[:created_at_lte].present?
    end
  end

  def show_order
    @trip_order = current_site.trip.trip_orders.find(params[:id])
    @valid = @trip_order.trip_ticket.valid_day
    render layout: 'application_pop', template: "pro/trips/show_order"
  end

  def order_status
    trip_order = current_site.trip.trip_orders.find(params[:id])
    trip_order.update_attributes(status: trip_order.status == 1 ? 2 : 1)
    render json: {id: params[:id]}
  end

end
