class BookingItem < ActiveRecord::Base
  belongs_to :booking
  belongs_to :booking_category

  has_many :booking_orders
  has_many :booking_comments
  has_many :booking_item_pictures

  validates :name, presence: true
  validates :price, presence: true, numericality: {greater_than: 0}
  validates :qty, presence: true, numericality: {only_integer: true, greater_than: 0}

  acts_as_enum :limit_type, :in => [
    ['no_limit', 1, '不限定'],
    ['time_limit', 2, '限定时间'],
    ['day_qty_limit', 3, '限定每日量'],
  ]

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  accepts_nested_attributes_for :booking_item_pictures, allow_destroy: true
  validates_associated :booking_item_pictures

  def sold_qty
    if day_qty_limit?
      booking_orders.where(["DATE(created_at) = DATE(?) and status >= ? ", Time.now, 0]).map(&:qty).sum.to_i
    else
      booking_orders.where(["status >= ?", 0]).map(&:qty).sum.to_i
    end
  end

  def surplus_qty
    if day_qty_limit?
      limit_qty - sold_qty
    else
      qty - sold_qty
    end
  end

  def little_time
    now = Time.now()
    start_at <= now && end_at >= now if time_limit?
  end

  def is_able_booking
    if day_qty_limit? or no_limit?
      surplus_qty > 0
    elsif time_limit?
      little_time
    else
      surplus_qty > 0
    end
  end

  def multilevel_menu params
    return [1, []] unless booking
    return [1, []] unless booking_category

    num, booking_categories_selects = booking_category.allow_menu_layer(1, true), []
    params["booking_category_id#{num}".to_sym] = booking_category.id

    if booking_category.parent_id == 0
      booking_categories_selects.unshift([num, booking.booking_categories.root.order(:sort)])
    else
      booking_categories_selects.unshift([num, booking_category.parent.try(:children)])
      booking_category.parent.try(:multilevel_menu_up, num - 1, params, booking_categories_selects)
    end

    booking_categories_selects
  end

end