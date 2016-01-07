class DbRedis

  class << self

    #记录一个用户某一轮摇的次数
    def set_user_shake_count(supplier_id, shake_round_id, shake_user_id)
      $redis.zincrby("shake:user_shake_count:#{supplier_id}:#{shake_round_id}", 1, shake_user_id)
    end

    #得到一个用户某一轮摇的次数
    def get_user_shake_count(supplier_id, shake_round_id, shake_user_id)
      $redis.zscore("shake:user_shake_count:#{supplier_id}:#{shake_round_id}", shake_user_id).to_i
    end

    #得到某一轮中前n名用户，次数由大到小
    def top_shake_round_users(supplier_id, shake_round_id, user_num, options = {})
      $redis.zrevrange("shake:user_shake_count:#{supplier_id}:#{shake_round_id}", 0, user_num - 1, options)
    end

    #得到某一轮的参与人数
    def get_shake_round_user_num(supplier_id, shake_round_id)
      $redis.zcard("shake:user_shake_count:#{supplier_id}:#{shake_round_id}")
    end

    #记录某一轮的参与人数
    def set_shake_round_user_num(supplier_id, shake_round_id, shake_user_id)
      $redis.sadd("shake:shake_round_user_num:#{supplier_id}:#{shake_round_id}", shake_user_id) unless $redis.sismember("shake:shake_round_user_num:#{supplier_id}:#{shake_round_id}", shake_user_id)
    end

    #记录一个用户某一轮摇的总次数
    def set_user_shake_total_count(supplier_id, shake_round_id, shake_user_id, count)
      $redis.zadd("shake:user_shake_count:#{supplier_id}:#{shake_round_id}", count, shake_user_id)
    end

    #得到某一轮的参与人数
    # def get_shake_round_user_num(supplier_id, shake_round_id)
    #   $redis.scard("shake:shake_round_user_num:#{supplier_id}:#{shake_round_id}")
    # end

    #记录用户购买会员卡套餐的id
    def set_vip_package_id(supplier_id, vip_user_id, vip_package_id)
      $redis.lpush("vip_package:vip_package_id:#{supplier_id}:#{vip_user_id}", vip_package_id)
    end 

    #获取用户购买会员卡套餐的id
    def get_vip_package_id(supplier_id, vip_user_id)
      $redis.lpop("vip_package:vip_package_id:#{supplier_id}:#{vip_user_id}")
    end 

  end

end