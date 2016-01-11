class SmsExpense < ActiveRecord::Base

  belongs_to :account
  
  enum_attr :status, :in => [
    ['succeed', 1, '发送成功'],
    ['not_sufficient', -4, '余额不足'],
    ['supplier_not_sufficient', -99, '商户套餐余额不足'],
  ]

  #收费模块
  enum_attr :operation_id, :in => [
      ['wshop', 1, '电商'],
      ['catering', 2, '餐饮'],
      ['hotel', 3, '酒店'],
      ['wplot', 4, '小区'],
      ['vip', 6, '会员卡'],
  ]

  FREE_MODULE = %w[微生活圈]

  class << self

    def get_operation_id_by_operation_name(operation_name)
      self.operation_id_options.each do |operation|
        return operation.last if operation.first == operation_name
      end
      0
    end

    def operations
      SmsExpense.operation_id_options.map(&:first) + FREE_MODULE
    end
  end

end
