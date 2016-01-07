class VipGiven < ActiveRecord::Base
  belongs_to :vip_user
  belongs_to :vip_care

  scope :usable, -> (date = Time.now) { unused.where('? BETWEEN vip_givens.start_at AND vip_givens.end_at',date) }
  scope :latest, -> { order('id DESC') }
  scope :point, -> { where('vip_givens.value is not null') }

  enum_attr :category, in: [
    ['festival',  1, '会员关怀'],
    ['birthday',  2, '生日关怀']
  ]

  enum_attr :status, in: [
    ['unused',  1, '未使用'],
    ['used',    2, '已使用'],
    ['expired', 3, '已过期']
  ]

end
