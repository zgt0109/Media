class FollowRedPacketWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: true, backtrace: true

  def self.send_follow_redpacket(wx_mp_user, wx_user)
    return unless wx_mp_user.present? and wx_user.present?

    follow_redpacket = RedPacket::FollowRedPacket.visible.where(supplier_id: wx_mp_user.supplier.id).first 
    return unless follow_redpacket.present?

    if follow_redpacket.can_send_redpacket? && !follow_redpacket.sent?(wx_user.uid)
      Rails.logger.info "Send follow red packet ====== supplier_id: #{wx_mp_user.supplier.id}, open_id: #{wx_user.uid}"
      FollowRedPacketWorker.perform_async(wx_mp_user.uid, wx_user.uid)
    end
  end

  def perform(wx_mp_user_openid, openid)
    logger.info "perform in FollowRedPacketWorker"

    return unless wx_mp_user_openid.present? and openid.present?
 
    wx_mp_user = WxMpUser.where(uid: wx_mp_user_openid).first
    wx_user = wx_mp_user.wx_users.where(uid: openid).first
    return unless wx_mp_user.present? and wx_user.present?

    follow_redpacket = RedPacket::FollowRedPacket.visible.where(supplier_id: wx_mp_user.supplier.id).first
    return unless follow_redpacket.present?
   
    if subscribe?(wx_mp_user, openid) && follow_redpacket.can_send_redpacket? && !follow_redpacket.sent?(openid)
      send_rec = follow_redpacket.send_records.where(uid: openid).first ||
                 follow_redpacket.send_records.create(supplier_id: wx_mp_user.supplier.id, wx_user_id: wx_user.id, uid: wx_user.uid, total_amount: follow_redpacket.total_amount, total_num: follow_redpacket.total_num, status: RedPacket::SendRecord::READY)

      logger.info "send follow red packet ======== wx_mp_user_uid = #{wx_mp_user.uid}, wx_user_uid = #{wx_user.uid}, red_packet_id = #{follow_redpacket.id}"

      send_rec.pay if send_rec.present?
    end
  end

  private
 
  def subscribe?(wx_mp_user, openid)
    hash = Weixin.get_wx_user_info(wx_mp_user, openid)

    hash['subscribe'].present? && hash['subscribe'] != 0
  end 
end
