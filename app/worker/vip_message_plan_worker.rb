class VipMessagePlanWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'standard', retry: true, backtrace: true

  def self.send_message(vip_message_plan)
    if vip_message_plan.send_at.present?
      time_diff = vip_message_plan.send_at - Time.now
      if time_diff > 0
        Sidekiq::Status.unschedule $redis.hget('vip_message_plan', vip_message_plan.id)
        job_id = VipMessagePlanWorker.perform_in(time_diff, vip_message_plan.id)
        $redis.hset('vip_message_plan', vip_message_plan.id, job_id)
      end
    else
      Sidekiq::Status.unschedule $redis.hget('vip_message_plan', vip_message_plan.id)
      VipMessagePlanWorker.perform_async(vip_message_plan.id)
      vip_message_plan.sent!
    end
  end

  def perform(id)
    plan = VipMessagePlan.where(id: id).first
    return unless plan

    receivers = plan.receivers
    supplier = plan.vip_card.supplier
    if receivers.present? && supplier.present?
      receivers.each do |receiver|
        # to be optimized to reuse title and content of plan.
        supplier.vip_user_messages.create(vip_user_id: receiver.id, title: plan.title, content: plan.content)
      end
    end
    plan.update_attributes vip_users_count: receivers.count, send_at: Time.now, skip_validate_send_at: true
  end
end