class PayTransaction < ActiveRecord::Base
  belongs_to :pay_account
  belongs_to :transactionable, polymorphic: true

  enum_attr :direction_type, :in => [
    ['settle',  11, '订单结算'],
    ['withdraw', 21, '商户提现']
  ]

  enum_attr :direction, :in => [
    ['income',  1, '收入'],
    ['outcome', 2, '支出']
  ]

end
