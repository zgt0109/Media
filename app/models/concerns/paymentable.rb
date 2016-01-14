module Paymentable
  extend ActiveSupport::Concern

  included do
    delegate :launch_push, to: "self.class"
  end

  def pay_result
    require_fields = %w(account_id out_trade_no trade_no status amount state subject body gmt_payment source)
    HashWithIndifferentAccess.new(attributes.slice(*require_fields))
  end

  def notify_push
    Thread.new { launch_push(notify_url, pay_result) }
  end

  module ClassMethods
    def launch_push(url, params)
      fiber = Fiber.new do
        uri = URI.parse(url)
        Net::HTTP.post_form(uri, params.as_json)
      end

      fiber.resume
    end
  end
end
