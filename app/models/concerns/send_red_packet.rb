module SendRedPacket
  extend ActiveSupport::Concern

  def follow_red_packet red_packet, wx_user
    logger.info "-----------------send redpacket with follow wx_user--------------------"
    options = {user_id: wx_user.user_id, openid: wx_user.openid}
    record = create_red_packet_send_record red_packet, options
    return nil unless record
    record.pay
  end

  def all_fans_red_packet red_packet
    wx_mp_user = red_packet.supplier.try(:wx_mp_user)
    return nil unless wx_mp_user
    logger.info "-----------------send redpacket with all fans--------------------"
    wx_mp_user.wx_users.subscribed.find_each do |wx_user|
      next unless subscribe? wx_mp_user, wx_user.openid
      options = {user_id: wx_user.user_id, openid: wx_user.openid}
      record = create_red_packet_send_record red_packet, options
      next unless record
      break unless pay record
    end
  end

  def all_vips_red_packet red_packet
    supplier = red_packet.supplier
    return nil unless supplier
    logger.info "-----------------send redpacket with all vips--------------------"
    supplier.vip_users.normal.find_each do |vip_user|
      options = {user_id: vip_user.user_id, openid: vip_user.wx_user_openid }
      record = create_red_packet_send_record red_packet, options
      next unless record
      break unless pay record
    end
  end

  def activity_red_packet red_packet, wx_user_id, activity_consume_id
    logger.info "=============send redpacket with activity=================="
    wx_user = WxUser.find_by_id(wx_user_id)
    logger.info "=============wx_user_present #{wx_user.present?}=================="
    return nil unless  wx_user

    activity_consume = ActivityConsume.find_by_id(activity_consume_id)
    logger.info "=============activity_consume_present #{activity_consume.present?}=================="
    return nil unless activity_consume
    

    logger.info "=============send_record #{activity_consume.send_record.present?}=================="
    if activity_consume.send_record.present?
      record = activity_consume.send_record
    else
      options = {
                      user_id: wx_user.user_id,
                      openid: wx_user.openid,
                      site_id: red_packet.site_id,
                      total_num: 1,
                      total_amount: red_packet.total_amount,
                      status: RedPacket::SendRecord::READY,
                      activity_id: red_packet.activity_id,
                      red_packet_id: red_packet.id,
                      activity_consume_id: activity_consume_id
                    }
      record = red_packet.send_records.create(options)
    end 
    return nil unless record
    pay record

    logger.info "=============record pay record_id_#{record.id}=================="
    #根据send_record的状态,修改对应的activity_consume记录的状态
    if record.failed? || record.ready?
      logger.info "=============change activity_consume status=================="
      activity_consume.update_attributes(status: ActivityConsume::UNSEND, use_at: nil)
    end

  end

  private

  def create_red_packet_send_record red_packet, **options
    # options.merge!(supplier_id: red_packet.supplier_id, total_num: 1, total_amount: red_packet.total_amount, status: RedPacket::SendRecord::READY)
    red_packet = red_packet.send_records.where(options).first_or_initialize(site_id: red_packet.site_id, total_num: 1, total_amount: red_packet.total_amount, status: RedPacket::SendRecord::READY)
    red_packet.save
    red_packet
  end

  def pay record
    result_code = record.pay
    if result_code.in? ["NOTENOUGH","TIME_LIMITED"]
      false
    else
      true
    end
  end

  def subscribe?(wx_mp_user, openid)
    hash = Weixin.get_wx_user_info(wx_mp_user, openid)

    hash['subscribe'].present? && hash['subscribe'] != 0
  end
end