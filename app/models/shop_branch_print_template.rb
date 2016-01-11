class ShopBranchPrintTemplate < ActiveRecord::Base
  belongs_to :shop_branch

  enum_attr :template_type, :in => [
    ['book_dinner',  1, '订餐小票'],
    ['take_out',     2, '外卖小票'],
    ['book_table',   3, '订座小票'],
    ['ec_order',     4, '电商小票']
  ]

  def name
    template_type_name
  end

  enum_attr :print_type, :in => [
    ['gprs', 1, 'gprs'],
    ['pc', 2, '直连']
  ]

  has_many :thermal_printers
  accepts_nested_attributes_for :thermal_printers, reject_if: proc { |attributes| attributes['no'].blank? }, allow_destroy: true

end