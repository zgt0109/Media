class BusinessShopImpression < ActiveRecord::Base
  belongs_to :business_shop
  belongs_to :comment
  STARS = [ ['很好', 1], ['好', 2], ['一般', 3], ['差', 4] ]

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  validates :avg_price, presence: true, numericality: { greater_than: 0 }
end
