class VipExternalHttpApi < ActiveRecord::Base
  belongs_to :site
  belongs_to :wx_mp_user
  belongs_to :vip_card

  acts_as_enum :api_type, in: [
    [ 'open_card',        1, '开卡' ],
    [ 'get_user_info',    2, '查询会员基本信息' ],
    [ 'get_transactions', 3, '查询会员流水' ]
  ]

  acts_as_enum :http_method, in: [
    [ 'get',  'GET' ],
    [ 'post', 'POST' ]
  ]

  validates :api_type, :path, :http_method, presence: true
  validates :api_type, uniqueness: { scope: :supplier_id }

end
