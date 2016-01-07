class DateTimeService
  class << self
    def second_to_day_hour_minute(seconds)
      day = seconds/(3600*24)
      seconds = seconds%(3600*24)
      hour = seconds/(3600)
      seconds = seconds%(3600)
      minute = seconds/(60)
      {'day' => day, 'hour' => hour, 'minute' => minute}
    end
  end
end