class Tryable
  def self.try_times!(n = 1, sleep_seconds: 0)
    n.times do
      begin
        return yield
      rescue => e
        Rails.logger.error "-- [#{Time.now}]: #{([e.message] + e.backtrace).join("\n")}"
        SiteLog::Base.logger('tryable', "Tryable error: #{([e.message] + e.backtrace).join("\n")}")
        sleep sleep_seconds if sleep_seconds > 0
      end
    end
    raise "Tryable#try_times run out of #{n} times"
  end
end