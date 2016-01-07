class VipPackageItem < ActiveRecord::Base
	has_and_belongs_to_many :vip_packages
	has_many :vip_package_item_consumes

	validates :name, :price, presence: true
	validates :price, numericality: { greater_than: 0 }

	enum_attr :status, :in => [
    ['normal',     1, '正常'],
    ['deleted',   -1, '删除']
  ]

  scope :latest, -> { order('created_at DESC') }
end
