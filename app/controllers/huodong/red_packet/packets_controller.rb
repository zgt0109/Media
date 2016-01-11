class Huodong::RedPacket::PacketsController < ApplicationController
  before_filter :require_wx_mp_user
  before_filter :find_packet, only: [:edit, :update, :show, :destroy]
  def index
    @total_packet_activities = current_site.activities.red_packet.show.order("id DESC")
    @search = @total_packet_activities.search(params[:search])
    @packet_activities = @search.page(params[:page])
  end

  def new
    @packet = ::RedPacket::Setting.new(activity: Activity.new(activity_type_id: 78))
    @options = {url: red_packet_packets_path, method: :POST}
    render :form
  end

  def edit
    return redirect_to red_packet_packet_path(@packet), alert: "活动已开始，不可修改！" if @packet.starting?
    @options = {url: red_packet_packet_path(@packet), method: :PUT}
    render :form
  end

  def create
    @packet = ::RedPacket::Setting.new(params[:red_packet_setting])
    if @packet.save
      redirect_to red_packet_packets_path, notice: "保存成功"
    else
      @options = {url: red_packet_packets_path, method: :POST}
      render_with_alert :form, "保存失败，#{@packet.errors.full_messages.first}"
    end
  end

  def update
    return redirect_to red_packet_packet_path(@packet), alert: "活动已开始，不可修改！" if @packet.starting?
    if @packet.update_attributes(params[:red_packet_setting])
      redirect_to red_packet_packets_path, notice: "保存成功"
    else
      @options = {url: red_packet_packet_path(@packet), method: :PUT}
      render_with_alert :form, "保存失败，#{@packet.errors.full_messages.first}"
    end
  end

  def show
    @options = {url: "", method: ""}
    render :form
  end

  def destroy
    @packet.mark_delete!
    redirect_to :back, notice: "操作成功"
  end

  def preview_template
    render layout: 'application_pop'
  end

  private
    def find_packet
      @packet = ::RedPacket::Setting.find(params[:id])
    end
end