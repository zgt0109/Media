module Concerns::OrderNoGenerator
  def self.generate
    now = Time.now
    [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
  end
end