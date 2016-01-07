class BusinessPrivilege < ActiveRecord::Base
  belongs_to :business_shop
  # attr_accessible :description, :end_at, :name, :start_at, :status
  validates :name, :description, :start_at, :end_at, presence: true

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]
end
