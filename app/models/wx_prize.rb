class WxPrize < ActiveRecord::Base
  belongs_to :wx_user
  belongs_to :activity

  enum_attr :status, :in => [
    ['not_reached', 0, '未达到'],
    ['reached', 1, '已达到'],
    ['abort', -1, '奖品已领完']
  ]

  def used_at
    consume.try(:used_at)
  end

  def code
    consume.try(:code)
  end

  def rqrcode
    return nil if code.blank?
    RQRCode::QRCode.new(code, :size => 4, :level => :h ).to_img.resize(90, 90).to_data_url rescue nil
  end

  def shop_name
    consume.try(:used?) ? consume.try(:use_shop_name) : ''
  end

  def finish!
    return if reached?
    transaction do
      if activity.extend.prize_type == 'custom'
        consume = Consume.where(wx_mp_user_id: activity.wx_mp_user_id, consumable_type: 'Activity', consumable_id: activity.id, wx_user_id: wx_user_id).first_or_create(expired_at: activity.extend.prize_end)
      elsif activity.extend.prize_type == 'coupon'
        coupon = Coupon.find_by_id(activity.extend.prize_id)
        consume = Consume.where(wx_mp_user_id: coupon.wx_mp_user_id,  consumable_type: 'Coupon', consumable_id: coupon.id, wx_user_id: wx_user_id).first_or_create(expired_at: activity.extend.prize_end)
      end
      update_attributes(consume_id: consume.id, status: REACHED) if consume.present?
    end
  end

  def consume
    Consume.find_by_id(consume_id)
  end
end