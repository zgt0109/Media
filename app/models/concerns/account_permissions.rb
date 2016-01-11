module AccountPermissions
  def permissions
    (statistics_permissions + order_permissions + vip_permissions).compact
  end

  def statistics_permissions
    %w[
      view_following_num
      view_vip_users_num 
      view_pv_num
      view_uv_num
    ]
  end

  def order_permissions
    permissions = []
    permissions << 'manage_ec_orders'            if has_industry_for?(AccountIndustry::INDUSTRY_COMMERCE)
    permissions << 'manage_hotel_orders'         if has_industry_for?(AccountIndustry::INDUSTRY_HOTEL)
    permissions << 'manage_car_orders'           if has_industry_for?(AccountIndustry::INDUSTRY_CAR)
    permissions << 'manage_house_orders'         if has_industry_for?(AccountIndustry::INDUSTRY_HOUSE)
    permissions << 'manage_catering_book_dinner' if has_industry_for?(AccountIndustry::INDUSTRY_FOOD)
    permissions << 'manage_takeout_orders'       if has_industry_for?(AccountIndustry::INDUSTRY_TAKEOUT)
    permissions << 'manage_plot_orders'          if has_industry_for?(AccountIndustry::INDUSTRY_PLOT)
    permissions << 'manage_reservation_orders'  #if has_industry_for?(AccountIndustry::INDUSTRY_PLOT)
    # permissions << 'manage_reservation_orders'   if has_industry_for?(AccountIndustry::INDUSTRY_PLOT)
  end

  def vip_permissions
    %w[
      manage_vip_consume
      manage_vip_recharge
      manage_vip_point
      manage_vip_gift_exchange
      manage_vip_money_adjustment
      manage_vip_package_release
    ]
  end

  def app_permissions
    APP_PERMISSIONS & permissions
  end

  def app_auth_info
    {
      id:                id,
      username:          nickname,
      role:              'supplier',
      token:             auth_token,
      expired_at:        expired_at.try(:strftime, '%F'),
      account_type_name: account_type_name,
      permissions:       app_permissions
    }
  end
end
