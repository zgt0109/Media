module Biz::ShopRelatedPathHelper
  def after_sign_in_path
    return shops_vip_deals_path                                                if can_manage_any_vip?
    return shops_vip_deals_path                                                if can_manage_marketing_sncode?
    return catering_path                                                       if can_manage_catering?
    return takeout_path                                                        if can_manage_takeout?
    return hotel_branch_path                                                   if can_manage_hotel?
  end

  def catering_path
    case
      when can?('manage_catering_book_rules')      then book_rules_path(rule_type: 1, industry_id: 10001)
      when can?('manage_catering_menus')           then shop_products_path(industry_id: 10001)
      when can?('manage_catering_book_dinner')     then shop_orders_path(industry_id: 10001)
      when can?('manage_catering_book_table')      then shop_table_orders_path(industry_id: 10001)
      when can?('manage_catering_reports')         then report_shop_orders_path(industry_id: 10001)
      when can?('manage_catering_reports_graphic') then graphic_shop_orders_path(industry_id: 10001)
    end
  end

  def takeout_path
    case
      when can?('manage_takeout_book_rules')      then book_rules_path(rule_type: 1, industry_id: 10002)
      when can?('manage_takeout_menus')           then shop_products_path(industry_id: 10002)
      when can?('manage_takeout_orders')          then shop_orders_path(industry_id: 10002)
      when can?('manage_takeout_reports')         then report_shop_orders_path(industry_id: 10002)
      when can?('manage_takeout_reports_graphic') then graphic_shop_orders_path(industry_id: 10002)
    end
  end

  def hotel_branch_path
    "#{HOTEL_HOST}/wehotel-all/admin/authToken?said=#{Des.encrypt(current_sub_account.id.to_s)}"
  end
end