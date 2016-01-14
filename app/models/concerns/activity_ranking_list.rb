module Concerns::ActivityRankingList

  RANK_NAMESPACE = "#{Rails.env}:winwemedia:micro_aid:rank:"
  READY          = 'ready'
  FINISHED       = 'finished'

  def rank_key()
    RANK_NAMESPACE + id.to_s
  end

  def add_score(score, member)
    $redis.zincrby rank_key, score.to_i, member.to_s
  end

  def get_score(member)
    $redis.zscore rank_key, member.to_s
  end

  def get_rank(member)
    rank = $redis.zrevrank rank_key, member.to_s
    (rank + 1) if rank.present?
  end

  def get_member(rank)
    return unless rank >= 1
    $redis.zrevrange rank_key, rank - 1, rank - 1, with_scores: true
  end

  # return : [key, key] or [[key, score]]
  def get_ranking_list(limit, start = 0,  with_scores = true)
    limit = [$redis.zcard(rank_key), limit].min
    limit -= 1 if limit > 0
    $redis.zrevrange rank_key, start, start + limit, with_scores: with_scores
  end

  def get_ranking_member_count(start = -Float::INFINITY, max = Float::INFINITY)
    $redis.zcount rank_key, start, max
  end

  def get_prize_by_ranking_list(member)
    rank = get_rank(member) if member.present?
    prizes = activity_prizes
    prize_counts = prizes.sum(:prize_count)

    # no prize
    return unless rank.present? && rank <= prize_counts

    # calc prize 
    total_count = 0
    prize = prizes.each do |prize|
      total_count += prize.prize_count 
      if rank <= total_count
        break prize
      end
    end
    prize.is_a?(Array) ? nil : prize
  end

  def delete_ranking_list
    $redis.del rank_key
    $redis.del rank_status_key
  end

  def rank_status_key
    rank_key + ':status'
  end

  # status: :ready, :finshed
  def ranking_list_status
    $redis.get rank_status_key
  end

  def ranking_list_ready!
    $redis.set rank_status_key, READY
  end

  def ranking_list_ready?
    ranking_list_status == READY
  end

  def ranking_list_finished!
    $redis.set rank_status_key, FINISHED 
  end
 
  # finished: has been processed 
  def ranking_list_finished?
    ranking_list_status == FINISHED
  end
end
