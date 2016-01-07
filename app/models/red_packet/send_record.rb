class RedPacket::SendRecord < ActiveRecord::Base
  belongs_to :activity
  belongs_to :activity_user
  belongs_to :wx_user
  belongs_to :supplier
  belongs_to :red_packet, class_name: RedPacket::RedPacket, counter_cache: :records_count
  belongs_to :activity_consume, class_name: "::ActivityConsume" 

  validates :wx_user, :red_packet, presence: true
  validates :uid, presence: true
  validates_uniqueness_of :uid, scope: [:supplier_id, :red_packet_id], if: :not_activity_redpacket?

  scope :need_query, -> { where("status not in (?)", [FAILED, RECEIVED, REFUND]) }

  before_create :generate_out_trade_no

  enum_attr :status, :in => [
    ['failed',  -1, '发送失败'],
    ['ready' ,   0, '商户未发送'],
    ['sended',   1, '商户已发送'],
    ['sending',  2, '发送中'],
    ['sent',     3, '已发送等待领取'],
    ['received', 4, '已领取'],
    ['refund',   5, '已退款'], 
  ]

  def pay
    return unless red_packet.can_send_redpacket? # judge buget balance

    pay_setting = get_pay_setting 
    return unless pay_setting.present?

    res = pay_setting.pay self
   
    result = HashWithIndifferentAccess.new(Hash.from_xml res.body)[:xml]
    logger.info "pay result ======== #{result}" 
    write_wxredpacket_log "pay result ========= #{result}"

    return_code = result[:return_code]

    if return_code == 'SUCCESS'
      write_wxredpacket_log "pay success ========= supplier_id = #{supplier.id}, out_trade_no = #{result[:mch_billno]}, openid = #{result[:re_openid]}, appid = #{result[:wxappid]}, total_amount = #{result[:total_amount]}, send_time = #{result[:send_time]}, send_listid = #{result[:send_listid]}"
      result_code = result[:result_code]
      if result_code == 'SUCCESS'
        update_attributes(send_at: result[:send_time], trans_id: result[:send_listid], status: RedPacket::SendRecord::SENDED)
        red_packet.update_attributes(budget_balance: red_packet.budget_balance.to_f - self.total_amount.to_f)
      else
        write_wxredpacket_log "pay fail ========= supplier_id = #{supplier.id}, out_trade_no = #{out_trade_no}, openid = #{uid}, total_amount = #{total_amount.to_f}, return_msg = #{result[:return_msg]}, err_code_des = #{result[:err_code_des]}"
        update_attributes(status: RedPacket::SendRecord::FAILED)
      end
    elsif return_code == 'FAIL'
      write_wxredpacket_log "pay fail ========= supplier_id = #{supplier.id}, out_trade_no = #{out_trade_no}, openid = #{uid}, total_amount = #{total_amount.to_f}, return_msg = #{result[:return_msg]}, err_code_des = #{result[:err_code_des]}"
      update_attributes(status: RedPacket::SendRecord::FAILED)
    else
      write_wxredpacket_log "pay some abnormal fail" 
    end
  end

  def query
    pay_setting = get_pay_setting 
    return unless pay_setting.present?

    res = pay_setting.query self

    status_old = self.status

    result = HashWithIndifferentAccess.new(Hash.from_xml res.body)[:xml]
    logger.info "query result ======== #{result}" 
    write_wxredpacket_log "query result ========= #{result}"

    return_code = result[:return_code]

    if return_code == 'SUCCESS'
      write_wxredpacket_log "query success ========= supplier_id = #{supplier.id}, status = #{result[:status]}, out_trade_no = #{result[:mch_billno]}, openid = #{result[:openid]}, appid = #{result[:wxappid]}, total_amount = #{result[:total_amount]}, total_num = #{result[:total_num]}, send_time = #{result[:send_time]}, refund_time = #{result[:refund_time]}, refund_amount = #{:refund_amount}"
      result_code = result[:result_code]
      if result_code == 'SUCCESS'
        update_attributes(status: transform_status(result[:status]), fault_reason: result[:reason], send_type: result[:send_type], hb_type: result[:hb_type], sent_at: result[:send_time], refunded_at: result[:refund_time], refund_amount: result[:refund_amount].to_i/100, detail_id: result[:detail_id])

        if self.received? && self.status != status_old # 模拟红包接收时间
          update_attributes(received_at: Time.now)
        end

        if self.refund? && self.status != status_old # 退款恢复相应的预算余额
          self.red_packet.update_attributes(budget_balance: self.red_packet.budget_balance.to_f + self.refund_amount.to_f)
        end
      else
        write_wxredpacket_log "query fail ========supplier_id = #{supplier.id}, out_trade_no = #{out_trade_no}, openid = #{uid}, total_amount = #{total_amount.to_f}, return_msg = #{result[:return_msg]}, err_code_des = #{result[:err_code_des]}"
      end
    elsif return_code == 'FAIL'
      write_wxredpacket_log "query fail ========supplier_id = #{supplier.id}, out_trade_no = #{out_trade_no}, openid = #{uid}, total_amount = #{total_amount.to_f}, return_msg = #{result[:return_msg]}, err_code_des = #{result[:err_code_des]}"
    else
      write_wxredpacket_log "query some abnormal fail" 
    end
  end


  # 是否需要query
  def query?
    !self.failed? && !self.received? && !self.refund? && !self.ready?
  end

  def not_activity_redpacket?
    !self.activity_consume.present?
  end

  private

  def get_pay_setting
    case 
    when red_packet.payment_type.wx_redpacket_pay?
      WxredpacketpaySetting.where(supplier_id: supplier.id, payment_type_id: red_packet.payment_type).first 
    end
  end

  def generate_out_trade_no
    self.out_trade_no = (Time.now.to_f.to_s.gsub('.', '') + Random.rand(999).to_s).slice(0..27)
  end

  def transform_status(status)
    case status.to_s
    when 'SENDING'
      RedPacket::SendRecord::SENDING
    when 'SENT'
      RedPacket::SendRecord::SENT
    when 'FAILED'
      RedPacket::SendRecord::FAILED
    when 'RECEIVED'
      RedPacket::SendRecord::RECEIVED
    when 'REFUND' 
      RedPacket::SendRecord::REFUND
    end
  end
end
