class ShopOrderReport < ActiveRecord::Base
  belongs_to :site
  belongs_to :shop
  belongs_to :shop_branch

  enum_attr :order_type, :in => [
    ['book_dinner', 1, '订餐'], 
    ['take_out', 2, '外卖']
  ]

  def shop_branch_name
    self.shop_branch.try(:name)
  end
end
