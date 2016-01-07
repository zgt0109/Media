# == Schema Information
#
# Table name: shop_order_reports
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  shop_id        :integer          not null
#  shop_branch_id :integer          not null
#  date           :date             not null
#  orders_count   :integer          default(0), not null
#  total_amount   :decimal(12, 2)   default(0.0), not null
#  pay_amount     :decimal(12, 2)   default(0.0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ShopOrderReport < ActiveRecord::Base
  belongs_to :supplier
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
