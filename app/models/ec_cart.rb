class EcCart < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  belongs_to :ec_item

  before_save :attrs_price

  def attrs_price
    item = EcItem.find(self.ec_item_id)
    self.price = item.price
    self.total_price = item.price * self.qty
  end

  def self.show_total_price carts
    sum = 0
    carts.select{|p| sum += p.total_price}
    return sum
  end

end
