class VipGradeLog < ActiveRecord::Base
	belongs_to :supplier
  belongs_to :vip_user
  belongs_to :operator, polymorphic: true
  belongs_to :shop_branch
end
