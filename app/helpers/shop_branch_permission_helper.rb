module ShopBranchPermissionHelper
  def has_permission_of?(key)
    case key
    when 'vip'      then true
    when 'activity' then true
    when 'catering' then current_user.has_privilege_for?(10001)
    when 'takeout'  then current_user.has_privilege_for?(10002)
    when 'hotel'    then current_user.has_privilege_for?(10005)
    end
  end
end