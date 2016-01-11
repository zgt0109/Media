class VipGradeLog < ActiveRecord::Base
	belongs_to :site
  belongs_to :vip_user
  belongs_to :operator, polymorphic: true
  belongs_to :shop_branch
end
