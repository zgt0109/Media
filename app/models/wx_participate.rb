class WxParticipate < ActiveRecord::Base
  belongs_to :wx_user
  belongs_to :activity
  has_many :wx_invites
  enum_attr :prize_status, :in => [
    ['not_reached', -2, '未达到'],
    ['no_prize', -1, '未兑奖'],
    ['got_prize', 1, '已兑奖']
  ]
  enum_attr :status, :in => [
    ['drop', -1, '已删除'],
    ['normal', 0, '正常']
  ]

  def check_prize!(to_wx_user_id)
    if activity.extend.prize_type == 'custom'
      gift_name = activity.extend.prize_name
      left_consumes_count =  activity.extend.prize_count.to_i - activity.consumes.count
      return if left_consumes_count <= 0
      consume = Consume.where(wx_mp_user_id: activity.wx_mp_user_id, consumable_type: 'Activity', consumable_id: activity.id, expired_at:  activity.extend.prize_end, wx_user_id: to_wx_user_id).first_or_create
    elsif activity.extend.prize_type == 'coupon'
      coupon = Coupon.find_by_id(activity.extend.prize_id)
      gift_name = coupon.name
      left_consumes_count = coupon.limit_count - coupon.consumes.count
      return if left_consumes_count <= 0
      consume = Consume.create(wx_mp_user_id: coupon.wx_mp_user_id,  consumable_type: 'Coupon', consumable_id: coupon.id, expired_at: coupon.use_end, wx_user_id: to_wx_user_id)
     end
     gift = WxPrize.where(wx_user_id: to_wx_user_id, activity_id: activity_id).first_or_create
     gift.update_attributes(consume_id: consume.id, prize_name: gift_name, status: 1) if consume.present?
     update_attributes(prize_status: WxParticipate::NO_PRIZE) if has_prize?
  end

  def recommended_count
    wx_invites.recommend.recommended.count
  end

  def prize_name
    got_prize? ? prize_title  : prize_status_name
  end

  #未兑奖的条件
  def has_prize?
    boundary = activity.activity_prizes.pluck(:recommends_count).uniq.compact.min
    (recommended_count >= boundary) && not_reached?
  end
end
