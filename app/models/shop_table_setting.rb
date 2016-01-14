class ShopTableSetting < ActiveRecord::Base
  belongs_to :site
  belongs_to :shop
  belongs_to :shop_branch
  # attr_accessible :date, :open_hall_count, :open_loge_count

  before_create :add_default_attrs
  
  validates_numericality_of  :open_loge_count, greater_than_or_equal_to: 0, presence: true, only_integer: true
  validates_numericality_of  :open_hall_count, greater_than_or_equal_to: 0, presence: true, only_integer: true
  
  def hall_table_booking_count_by_date
    shop_branch.shop_table_orders.hall_table.pending.by_date(date).count + shop_branch.shop_table_orders.hall_table_first.pending.by_date(date).count
  end
  
  def loge_table_booking_count_by_date
    shop_branch.shop_table_orders.loge_table.pending.by_date(date).count + shop_branch.shop_table_orders.loge_table_first.pending.by_date(date).count
  end

  private

  def add_default_attrs
    return unless self.shop_branch

    self.shop_id = self.shop_branch.shop_id
    self.site_id = self.shop_branch.site_id
  end
end
