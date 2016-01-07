class RedPacketWorker
  include Sidekiq::Worker
  include SendRedPacket
  sidekiq_options :queue => 'standard', :retry => true, :backtrace => true

  def perform(red_packet_id, wx_user_id = nil, activity_consume_id = nil)
    red_packet = RedPacket::RedPacket.find_by_id(red_packet_id)
    return nil unless red_packet || red_packet.normal?
    @red_packet = red_packet
    case red_packet.receive_type
      when RedPacket::RedPacket::FOLLOW
        #follow_red_packet red_packet, wx_user 关注红包没有使用这个方法
      when RedPacket::RedPacket::ALL_FANS
        all_fans_red_packet red_packet
      when RedPacket::RedPacket::ALL_VIPS
        all_vips_red_packet red_packet
      when RedPacket::RedPacket::UID
        activity_red_packet red_packet, wx_user_id, activity_consume_id
      when RedPacket::RedPacket::GROUP

    end
  end

  def self.subscribe_red_packet from_user_name, to_user_name
    wx_mp_user = WxMpUser.find_by_uid(from_user_name)
    return unless wx_mp_user
    RedPacketWorker.perform_async((wx_mp_user.supplier.red_packets.follow.normal.last.id rescue ''), to_user_name)
  end

end