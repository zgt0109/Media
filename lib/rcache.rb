# -*- encoding : utf-8 -*-
class Rcache

  CACHE_PREFIX = "rc_"

  class << self

    def set(origin_key, value, expires_in = 2.days)
      key = CACHE_PREFIX + origin_key.to_s.strip
      $redis.set key, Marshal.dump(value)
      $redis.expire key, expires_in
      value
    end

    def get(origin_key)
      key = CACHE_PREFIX + origin_key.to_s.strip      
      result = $redis.get(key)
      return nil if result.nil?
      Marshal.load(result)
    end

    def fetch(origin_key, expires_in = 2.days)
      result = self.get(origin_key)
      return result unless result.nil?
      self.set(origin_key, yield, expires_in)
    end

  end

end
