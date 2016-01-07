# == Schema Information
#
# Table name: shop_order_items
#
#  id              :integer          not null, primary key
#  supplier_id     :integer          not null
#  wx_mp_user_id   :integer          not null
#  shop_id         :integer          not null
#  shop_branch_id  :integer          not null
#  shop_order_id   :integer          not null
#  shop_product_id :integer          not null
#  product_name    :string(255)      not null
#  qty             :integer          default(0), not null
#  price           :decimal(12, 2)   default(0.0), not null
#  discount        :decimal(6, 2)    default(0.0)
#  total_price     :decimal(12, 2)   default(0.0), not null
#  total_pay_price :decimal(12, 2)   default(0.0), not null
#  status          :integer          default(1), not null
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ShopOrderItem < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :shop
  belongs_to :shop_branch
  belongs_to :shop_order
  belongs_to :shop_product
  # attr_accessible :description, :price, :product_name, :qty, :status, :total_price

  before_create :add_default_attrs

  before_save  :cal_item_price
  after_save :cal_shop_order_amount
  after_destroy :cal_shop_order_amount

  def increment_quantity!
    self.increment!(:qty)
  end

  def decrement_quantity!
    if self.qty > 1
      self.decrement!(:qty)
    else
      self.destroy
    end
  end

  def product_name_to_4
    # if contain_cn(self.product_name)
    #   self.product_name.ljust(10) 
    # else
    #   self.product_name.ljust(12) 
    # end
    if self.product_name.length > 6
      return self.product_name[0,6]
    end
    return self.product_name
  end

  def contain_cn(str)
    ret = true
    str.each_char do |e|
      if ("a".."z") === e || ("A".."Z")=== e || ("1".."9") === e
      else
        return true
      end
    end
    return false
  end

  def show_price 
    if self.shop_product.try(:is_current_price)
      return "时价"
    else
      return print_f self.total_price.to_f 
    end
  end

  private

  def add_default_attrs
    return unless self.shop_product
    self.supplier_id = self.shop_product.supplier_id
    self.wx_mp_user_id = self.shop_product.wx_mp_user_id
    self.shop_id = self.shop_product.shop_id
    self.shop_branch_id = self.shop_order.shop_branch.id
    self.product_name = self.shop_product.name
    self.qty = 1
    self.price = self.shop_product.try(:price)
    self.discount = self.shop_product.try(:discount)
    if self.shop_product.is_current_price
      self.total_price = 0
    else
      self.total_price = price * qty 
    end
  end

  def cal_shop_order_amount
    self.shop_order.total_amount = self.shop_order.shop_order_items.sum(:total_price)
    self.shop_order.pay_amount = self.shop_order.shop_order_items.sum(:total_pay_price)
    self.shop_order.save
  end

   def cal_item_price
    if self.shop_product.is_current_price
      self.total_price = 0
    else
      self.total_price = price * qty
    end
  end



  def print_f(float)
    num = format("%0.1f", float)
    # b = 7 - num.length #最大5位数
    # b = 0 if b < 0
    # ret = " " * b + num.to_s
    # ret
    num.to_s
  end

end
