class Brokerage::CommissionType < ActiveRecord::Base
  belongs_to :activity
  validates :mission_type, uniqueness: { scope: :activity_id }
  validates :commission_value, numericality: { greater_than_or_equal_to: 0.0 }
  scope :higher_than, -> (commission_type) { where('brokerage_commission_types.id > ?', commission_type.try(:id)) }

  SORT_FIELD = :mission_type

  acts_as_enum :mission_type, in: [
    ['new_client',   1, '新客户'],
    ['uninterested', 2, '无意向'],
    ['interested',   3, '有意向'],
    ['visited',      4, '已到访'],
    ['ordered',      5, '已订购'],
    ['purchased',    6, '已购买']
  ]

  acts_as_enum :commission_type, in: [
    ['ready_money',      1, '赠现金'],
    ['call_charge',      2, '赠话费'],
    ['down_payment_per', 3, '赠送定金的百分比'],
    ['price_per',        4, '赠送价格的百分比']
  ]

  enum_attr :status, :in => [
    ['enabled',   1, '已启用'],
    ['disabled', -1, '已停用']
  ]

  def commission_value_text
    if ready_money?
      "#{commission_value}元现金"
    elsif call_charge?
      "#{commission_value}元话费"
    elsif down_payment_per?
      "定金的#{commission_value}%"
    elsif price_per?
      "价格的#{commission_value}%"
    end
  end

  def >(other)
    return true if other.nil?
    self[SORT_FIELD] > other[SORT_FIELD]
  end

  def get_commission(client_commission)
    if ready_money? || call_charge?
      commission_value
    else
      client_commission  * (commission_value / 100.0)
    end
  end

  def mission_type_name_with_id
    [mission_type_name, id]
  end
end
