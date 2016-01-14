class ShopOrderItem < ActiveRecord::Base
  belongs_to :site
  belongs_to :shop
  belongs_to :shop_branch
  belongs_to :shop_order
  belongs_to :shop_product

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
    self.site_id = self.shop_product.site_id
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
