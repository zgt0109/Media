# == Schema Information
#
# Table name: point_gift_exchanges
#
#  id            :integer          not null, primary key
#  supplier_id   :integer
#  vip_user_id   :integer          not null
#  point_gift_id :integer          not null
#  total_points  :integer          default(0), not null
#  qty           :integer          default(0), not null
#  status        :integer          default(1), not null
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PointGiftExchange < ActiveRecord::Base
  belongs_to :site
  belongs_to :vip_user
  belongs_to :point_gift
  has_one :consume, as: :consumable
  
  scope :latest, -> { order('created_at DESC') }

  enum_attr :status, :in => [
    ['unused', 1, '未领取'],
    ['used',   2, '已领取']
  ]

  def usable?
  	unused? && consume && consume.unexpired?
  end

end
