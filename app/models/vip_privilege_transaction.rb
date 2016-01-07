class VipPrivilegeTransaction < ActiveRecord::Base
  belongs_to :vip_user
  belongs_to :vip_privilege

  def self.create_recharge_transaction(vip_user, recharge_given_privilege, recharge_discount_privilege)
    return unless vip_user

    [recharge_given_privilege, recharge_discount_privilege].compact.each do |vip_privilege|
      vip_user.vip_privilege_transactions.create!(vip_privilege: vip_privilege)
    end
  end
end
