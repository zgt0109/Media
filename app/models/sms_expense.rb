class SmsExpense < ActiveRecord::Base

  belongs_to :account

  enum_attr :status, :in => [
    ['succeed', 1, '发送成功'],
    ['not_sufficient', -4, '余额不足'],
    ['account_not_sufficient', -99, '商户套餐余额不足'],
  ]

  #收费模块
  enum_attr :operation_id, :in => [
    ['vip', 1, '会员卡'],
    ['ec', 2, '电商'],
    ['catering', 3, '餐饮'],
    ['hotel', 4, '酒店'],
    ['plot', 5, '小区'],
    ['activity', 6, '活动'],
    ['other', 7, '其它']
  ]

  # 微生活圈: 6
  FREE_MODULE = %w[6]

  def self.operations
    operation_id_options.map(&:last) + FREE_MODULE
  end

end
