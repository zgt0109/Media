class PaymentSync < ActiveRecord::Base
  belongs_to :payment

  # attr_accessible :title, :body
  LIMIT_SYNC_COUNT = 500

  # L1  3.minutes  ttl: 2.hours
  # L2  10.minutes   ttl: 6.hours
  # L3  15.minutes    ttl: 2.days
  # L4  30.minutes    ttl: 7.days
  # L5  1.hours    ttl: 3.months
  FREQUENCY_LEVEL_MAP = HashWithIndifferentAccess.new({
    level_1: {frequency: 3.minutes, ttl: 2.hours},
    level_2: {frequency: 10.minutes, ttl: 6.hours},
    level_3: {frequency: 15.minutes, ttl: 2.days},
    level_4: {frequency: 30.minutes, ttl: 7.days},
    level_5: {frequency: 1.hours, ttl: 3.months}
  })

  enum_attr :status, :in => [
    ['pending', '等待中'],
    ['syncing', '同步中'],
    ['exceed_sync_count', '超出最大同步次数'],
    ['finished', '完成'],
    ['invaild', '无效']
  ]

  after_initialize do
    self.status ||= :pending
    self.frequency_level ||= 1
    self.occur_count ||= 0
  end

  def mark_as_response_sucess
    update_attributes(status: :finished)
    payment.update_attributes(is_trade_synced: true)
  end

  def mark_as_exceed_sync_count
    update_attributes(status: :exceed_sync_count)
  end

  def should_enqueue?
    pending? and occur_count <= LIMIT_SYNC_COUNT
  end

  def enqueue_to_mq
    $rabbitmq.start
    rabbitmq_channel = $rabbitmq.create_channel
    rabbitmq_queue = rabbitmq_channel.queue("payment_sync")
    rabbitmq_queue.publish({payment_sync_id: self.id}.to_yaml)
    $rabbitmq.close
  end

  class << self
    def batch_enqueue_to_mq(payment_syncs)
      $rabbitmq_lazy.call {|conn|
        rabbitmq_channel = conn.create_channel
        rabbitmq_queue = rabbitmq_channel.queue("payment_sync")
        payment_syncs.each {|payment_sync|  rabbitmq_queue.publish({payment_sync_id: payment_sync.id}.to_yaml)}
      }
    end

    def push_all_pending_to_mq
      # where(status: "pending").find_each(batch_size: 2000).map(&:id)
      where(status: "pending").find_in_batches(batch_size: 2000) do |payment_syncs|
        batch_enqueue_to_mq(payment_syncs)
      end
    end
  end
end
