# == Schema Information
#
# Table name: shop_table_orders
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  wx_mp_user_id  :integer          not null
#  wx_user_id     :integer          not null
#  shop_id        :integer          not null
#  shop_branch_id :integer          not null
#  table_type     :integer          default(1), not null
#  order_no       :string(255)      not null
#  booking_at     :datetime         not null
#  booking_count  :integer          default(0), not null
#  mobile         :string(255)      not null
#  status         :integer          default(1), not null
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ShopTableOrder < ActiveRecord::Base
  # attr_accessible :booking_at, :booking_count, :description, :mobile, :order_no, :status, :table_type

  enum_attr :table_type, :in => [
    ['loge_table', 1, '只要包厢'],
    ['hall_table', 2, '只要大厅'],
    ['hall_table_first', 3, '优先大厅，包厢也可'],
    ['loge_table_first', 4, '优先包厢，大厅也可']
  ]

  enum_attr :status, :in => [
    ['pending',1,'待处理'],
    ['completed',2,'已完成'],
    ['canceled',-1,'已流单'],
    ['half', -9, '失败']
  ]

  scope :active, -> { where(status: [PENDING, COMPLETED]) }
  scope :by_date, proc { |date| where('DATE(shop_table_orders.booking_at) = ?', date) }

  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :wx_user
  belongs_to :shop
  belongs_to :shop_branch

  before_create :add_default_attrs
  before_create :update_user_mobile
  after_create :igetui

  def complete!
    update_attributes(status: COMPLETED)
  end

  def cancel!
    update_attributes(status: CANCELED)
  end

  # def validate_money
  #   if self.shop_branch.book_table_rule.is_limit_money
  #     if self.shop_branch.take_out_rule.min_money <= self.total_amount

  #     else
  #       return false
  #     end
  #   end

  # end

  def ref_order 
    ShopOrder.where(id: self.ref_order_id).first || ShopOrder.where(ref_order_id: self.id).first
  end


  def can_cancel?

    rule = self.shop_branch.book_table_rule
    if rule.cancel_rule == -1
      return true
    elsif rule.cancel_rule == -2
      return false
    elsif rule.cancel_rule == -3
      if Time.now.ago(rule.created_minute.minutes) > self.created_at
        return false
      end
    end
    return true  
 
  end

  def title
    if self.description.blank?
      ""
    else
      ar = self.description.scan(/.{1,10}/)
      ar.join("&#10;")
    end
  end 

  def clone_order
    new_shop_table_order = self.dup
  end

  private

  def add_default_attrs
    now = Time.now
    self.order_no = [now.strftime('%Y%m%d'), now.usec.to_s.ljust(6, '0')].join

    return unless self.shop_branch

    self.supplier_id = self.shop_branch.supplier_id
    self.wx_mp_user_id = self.shop_branch.wx_mp_user_id
    self.shop_id = self.shop_branch.shop_id

    ref_order = ShopOrder.where(id: self.ref_order_id).first
    if ref_order
      self.mobile = ref_order.mobile
      self.username = ref_order.username
    end
  end

  def update_user_mobile
    self.wx_user.mobile = self.mobile if self.mobile && self.wx_user
    self.wx_user.nil? ? self.build_wx_user(:nickname => self.username) : self.wx_user.nickname = self.username if self.username
    self.wx_user.save if self.wx_user
  end

  def igetui
    begin
      RestClient.post("#{MERCHANT_APP_HOST}/v1/igetuis/igetui_app_message", {role: 'supplier', role_id: supplier_id, token: supplier.try(:auth_token), messageable_id: self.id, messageable_type: 'ShopTableOrder', source: 'winwemedia_shop_table_order', message: '您有一笔新的微餐饮订单, 请尽快处理'})
    rescue => e
      Rails.logger.info "#{e}"
    end
  end
end
