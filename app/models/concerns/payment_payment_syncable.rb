module PaymentPaymentSyncable
  extend ActiveSupport::Concern

  included do
    has_one :payment_sync

    scope :need_sync, -> { where("is_trade_synced is not ?", true) }

    after_update :trigger_sync, if: -> { should_sync? }
  end

  def should_sync?
    success? and ! is_trade_synced
  end

  def bind_payment_sync
    _payment_sync = payment_sync || create_payment_sync
  end

  def trigger_sync
    _payment_sync = bind_payment_sync
  end

  module ClassMethods
    def enqueue_to_sync
      need_sync.map(&:trigger_sync)
    end
  end
end
