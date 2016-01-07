class BaiduApp < ActiveRecord::Base

  enum_attr :status, :in => [
    ['pending', 2, '审核中'],
    ['denid', 3, '审核不通过'],
    ['passed', 4, '审核通过'],
    ['offline', 7, '管理员下线'],
    ['deleted', 9, '管理员删除'],
  ]

end
