class Biz::RedPacketsController < ApplicationController

  before_filter :find_payment_setting, only: :payment_setting_new
  before_filter :find_red_packet, only: [:show, :edit, :update, :destroy]

  def index
    @search = current_site.red_packets.normal.where("type is not null").search(params[:search])
    @red_packets = @search.order("receive_type asc").page(params[:page])
  end

  def off_or_on
    @red_packet = RedPacket::FollowRedPacket.find_by_site_id(current_site.id)
    if @red_packet
      if @red_packet.normal?
        @red_packet.deleted!
      else
        @red_packet.update_attributes({send_at: Time.now, status: RedPacket::RedPacket::NORMAL, nick_name: current_site.wx_mp_user.try(:nickname), send_name: current_site.wx_mp_user.try(:nickname)})
      end
    else
      # @red_packet.normal!
      attr = {
          site_id: current_site.id,
          payment_type_id: PaymentType::WX_REDPACKET_PAY,
          act_name: '关注红包',
          nick_name: current_site.wx_mp_user.try(:nickname),
          send_name: current_site.wx_mp_user.try(:nickname),
          wishing: '恭喜发财,大吉大利',
          remark: '微枚迪技术支持',
          total_amount: 1,
          min_value: 1,
          max_value: 1,
          total_num: 1,
          total_budget: 100,
          budget_balance: 100,
          receive_type: RedPacket::RedPacket::FOLLOW,
          send_at: Time.now
      }
      RedPacket::FollowRedPacket.follow.normal.create(attr)
    end
    render js: "showTip('success', '操作成功');"
  end

  def set_value
    @red_packet = RedPacket::FollowRedPacket.normal.where(site_id: current_site.id).first
    render layout: 'application_pop'
  end

  def update_follow_packet
    @red_packet = RedPacket::FollowRedPacket.normal.find_by_id_and_site_id(params[:red_packet_id], current_site.id)
    before_budget = @red_packet.total_budget
    attr = {
        min_value: params[:red_packet_follow_red_packet][:min_value],
        max_value: params[:red_packet_follow_red_packet][:min_value],
        total_amount: params[:red_packet_follow_red_packet][:min_value],
        total_budget: params[:red_packet_follow_red_packet][:total_budget]
    }
    @red_packet.attributes = attr
    @red_packet.set_budget_balance(before_budget)
    if @red_packet.save
      flash[:notice] = '操作成功'
      render inline: "<script>window.parent.location.href = '#{settings_red_packets_url}';</script>"
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def new
    @red_packet = RedPacket::EventRedPacket.normal.new
  end

  def create
    attr = {
        site_id: current_site.id,
        payment_type_id: PaymentType::WX_REDPACKET_PAY,
        nick_name: current_site.wx_mp_user.try(:nickname),
        send_name: current_site.wx_mp_user.try(:nickname),
        wishing: '恭喜发财,大吉大利',
        remark: '微枚迪技术支持',
        budget_balance: params[:red_packet_event_red_packet][:total_budget],
        total_amount: params[:red_packet_event_red_packet][:min_value],
        max_value: params[:red_packet_event_red_packet][:min_value],
        total_num: 1
    }
    @red_packet = RedPacket::EventRedPacket.normal.new(params[:red_packet_event_red_packet].merge!(attr))
    if @red_packet.save
      sidekiq_and_redis_task "create"
      redirect_to settings_red_packets_url, notice: '红包创建成功'
    else
      redirect_to settings_red_packets_url, alert: "保存失败"
    end
  end

  def update
    return redirect_to red_packets_path, alert: '活动已经开始,不允许修改' unless @red_packet.send_at > Time.now
    before_budget = @red_packet.total_budget
    attr = {nick_name: current_site.wx_mp_user.try(:nickname), send_name: current_site.wx_mp_user.try(:nickname)}
    @red_packet.attributes = params[:red_packet_event_red_packet].merge(attr)
    @red_packet.set_budget_balance(before_budget)
    if @red_packet.save
      sidekiq_and_redis_task "update"
      flash[:notice] = '操作成功'
      render inline: "<script>window.parent.location.href = '#{red_packets_url}';</script>"
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def show
    @all_records = @red_packet.send_records
    @records = @all_records.page(params[:page])
  end

  def destroy
    return redirect_to :back, alert: '这个红包不允许删除' if @red_packet.send_at <= Time.now && Time.now  <= @red_packet.send_at + 4.days
    if @red_packet.deleted!
      sidekiq_and_redis_task "delete"
      redirect_to red_packets_path, notice: "删除成功"
    else
      redirect_to red_packets_path, alert: "删除失败"
    end
  end

  def payment_setting_new
    render layout: 'application_pop'
  end

  def payment_setting
    attrs = params[:wxredpacketpay_setting]
    attrs[:api_client_cert] = params[:wxredpacketpay_setting][:api_client_cert].try(:read) if params[:wxredpacketpay_setting][:api_client_cert].present?
    attrs[:api_client_key] = params[:wxredpacketpay_setting][:api_client_key].try(:read) if params[:wxredpacketpay_setting][:api_client_key].present?

    @wxredpacketpay = WxredpacketpaySetting.where(site_id: current_site.id, payment_type_id: PaymentType::WX_REDPACKET_PAY).first
    if @wxredpacketpay.present? # 红包支付已存在，修改红包
      @wxredpacketpay.update_attributes(attrs)
    else # 新建红包支付
      @wxredpacketpay = WxredpacketpaySetting.create(attrs)
    end
    if @wxredpacketpay.errors.blank?
      flash[:notice] = '操作成功'
      render inline: "<script>window.parent.location.href = '#{settings_red_packets_url}';</script>"
    else
      redirect_to :back, alert: '操作失败'
    end
  end

  def export
    if params[:receive_type].to_i == RedPacket::RedPacket::ALL_FANS
      @users = current_site.wx_mp_user.wx_users.subscribed.page(params[:page_exl]).per(EXPORTING_COUNT)
    else
      @users = current_site.vip_users.normal.page(params[:page_exl]).per(EXPORTING_COUNT).map{|vip_user| vip_user.wx_user if vip_user.wx_user.present?}.compact
    end
    if params[:format] == "xls"
      options = {
          header_columns: %w(用户昵称 Openid),
          only: [:nickname, :openid]
      }
      respond_to do |format|
        #send_data(@search.page(params[:page_exl]).per(EXPORTING_COUNT).to_xls(options))
        format.xls { send_data(@users.to_a.to_xls(options), :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/, '_') + rand(99999).to_s + ".xls") }
      end
    else
      open_ids = @users.map { |user| user.openid }
      open_ids.insert(0,current_site.wx_mp_user.app_id)
      send_data(open_ids.join("\r\n"), type: "text", :filename => Time.now.to_s(:db).to_s.gsub(/[\s|\t|\:]/, '_') + rand(99999).to_s + ".txt")
    end
  end

  def test_pay
    @red_packet = current_site.red_packets.new
    attr = {
        payment_type_id: PaymentType::WX_REDPACKET_PAY,
        act_name: '测试红包',
        nick_name: current_site.wx_mp_user.try(:nickname),
        send_name: current_site.wx_mp_user.try(:nickname),
        wishing: '恭喜发财,大吉大利',
        remark: '微枚迪技术支持',
        total_amount: 1.00,
        min_value: 1.00,
        max_value: 1.00,
        total_num: 1,
        total_budget: 1,
        budget_balance: 1,
        send_at: Time.now
    }
    @red_packet = current_site.red_packets.create(attr)
    if @red_packet.errors.blank?
      re_attr = {
          site_id: current_site.id,
          user_id: current_site.wx_mp_user.wx_users.where(openid: params[:test_openid]).first.try(:user_id),
          red_packet_id: @red_packet.id,
          openid: params[:test_openid],
          total_amount: @red_packet.total_amount,
          total_num: @red_packet.total_num
      }
      @record = @red_packet.send_records.create(re_attr)
      if @record.errors.blank?
        @record.pay
        redirect_to :back, notice: '测试完成'
      else
        redirect_to :back, alert: '测试失败'
      end
    else
      redirect_to :back, alert: '测试失败'
    end
    @red_packet.deleted!
  end

  private

  def find_payment_setting
    weixinpay = current_site.payment_settings.where(payment_type_id: PaymentType::WEIXINPAY).first
    #@wxredpacketpay = current_site.payment_settings.where(payment_type_id: PaymentType::WX_REDPACKET_PAY).first ||
    @wxredpacketpay = WxredpacketpaySetting.where(site_id: current_site.id, payment_type_id: PaymentType::WX_REDPACKET_PAY).first ||
        WxredpacketpaySetting.new(
            site_id: current_site.id,
            payment_type_id: PaymentType::WX_REDPACKET_PAY,
            partner_id: weixinpay.try(:partner_id) || '',
            partner_key: weixinpay.try(:partner_key) || '',
            app_id: weixinpay.try(:app_id) || '',
            api_client_cert: '',
            api_client_key: '')
  end

  def find_red_packet
    @red_packet = RedPacket::RedPacket.normal.find_by_id_and_site_id(params[:id], current_site.id)
    return redirect_to :back, alert: '数据不存在' unless @red_packet
  end

  def sidekiq_and_redis_task action
    redis_key = "red_packet_id_#{@red_packet.id}"
    case action.to_s
      when "create"
        jid = RedPacketWorker.perform_at @red_packet.sidekiq_task_time.seconds.from_now, @red_packet.id
        $redis.set(redis_key, jid, {ex: (@red_packet.sidekiq_task_time + 3600)})
      when "update"
        sidekiq_and_redis_task "delete"
        sidekiq_and_redis_task "create"
      when "delete"
        jid = $redis.get(redis_key)
        Sidekiq::Status.cancel jid
        $redis.del redis_key
    end
  end

end
