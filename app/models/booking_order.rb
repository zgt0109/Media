class BookingOrder < ActiveRecord::Base
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :wx_user
  belongs_to :booking_item

  acts_as_enum :status, :in => [
    ['pending', 1, '待处理'],
    ['completed', 2, '已完成'],
    ['canceled', 3, '已取消'],
  ]

  scope :latest, -> { order('created_at DESC') }

  before_create :add_default_attrs, :generate_order_no
  
  def complete!
    update_attributes(status: COMPLETED, completed_at: Time.now)
  end
  
  def cancele!
    update_attributes(status: CANCELED, canceled_at: Time.now)
  end

  def self.flow_suppliers
    case Rails.env
      when 'production'  then [19198]
      when 'staging'     then [19198]
      when 'testing'     then [10041]
      when 'dev'         then [10041]
      when 'development' then [10116]
      else [10116]
    end
  end

  def is_flow_supplier
    self.class.flow_suppliers.include?(supplier_id)
  end

  private

  def add_default_attrs
    if booking_item
      self.supplier_id = booking_item.supplier_id
      self.wx_mp_user_id = booking_item.wx_mp_user_id
      self.price = booking_item.price
      self.total_amount = self.price * self.qty
    else
      self.price = 0
      self.total_amount = 0
    end
  end

  def generate_order_no
    now = Time.now
    self.order_no = [now.to_s(:number), now.usec.to_s.ljust(6, '0')].join
  end

end
