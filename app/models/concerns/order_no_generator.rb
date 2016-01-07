module Concerns::OrderNoGenerator
  def self.generate
    order_no = [Time.now.to_s(:number), Time.now.usec.to_s.ljust(6, '0')].join
  end
end