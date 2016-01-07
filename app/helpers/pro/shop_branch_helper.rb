module Pro::ShopBranchHelper
  def industry_food?
    session[:current_industry_id] == 10001 || current_user.industry_food?
  end

  def industry_takeout?
    session[:current_industry_id] == 10002 || current_user.industry_takeout?
  end

  def industry_food_path?
    industry_food? && (controller_name =~ /^book_rules|shop_branches|shop_products|shop_categories|shop_orders|shop_table_orders|shop_table_settings|shop_menus$/ || request.path == '/shops')
  end

  def industry_takeout_path?
    industry_takeout? && (controller_name =~ /^book_rules|shop_branches|shop_products|shop_categories|shop_orders|shop_table_orders|shop_table_settings|shop_menus$/ || request.path == '/shops')
  end

  def book_rules_path?
    controller_name == 'book_rules'
  end

  def industry_food_book_rules_path?
    industry_food? && book_rules_path?
  end

  def industry_takeout_book_rules_path?
    industry_takeout? && book_rules_path?
  end

  def catering_menus_path?
    industry_food? && controller_name =~ /shop_products|shop_categories/
  end

  def takeout_menus_path?
    industry_takeout? && controller_name =~ /shop_products|shop_categories/
  end

end