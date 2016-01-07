class VipPackageItemsVipPackage < ActiveRecord::Base
	belongs_to :vip_package
	belongs_to :vip_package_item
	has_many :vip_package_item_consumes

	validates :items_count, numericality: {greater_than_or_equal_to: -1, only_integer: true}, exclusion: { in: [0], message: '不能等于0' }

	def used_count(vpvu_id)
		vip_package_item.vip_package_item_consumes.used.where(vip_packages_vip_user_id: vpvu_id).count
	end
end
