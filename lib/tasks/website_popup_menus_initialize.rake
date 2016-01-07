# -*- encoding : utf-8 -*-
namespace :website_popup_menus_initialize do

  desc '初始化导航菜单内容'
  
  task :website_popup_menus => :environment do

    home_template_relate_to_nav_template = {
      16 => 8,
      6 => 1,
      13 => 5,
      14 => 6,
      36 => 14,
      47 => 15,
      53 => 16,
      61 => 17,
      66 => 18,
      70 => 19,
      75 => 20,
      77 => 22,
      78 => 21,
      80 => 23,
      83 => 24,
    }
    settings = WebsiteSetting.where(:home_template_id => home_template_relate_to_nav_template.keys)
    settings.each do |setting|
      # 根据用户选择的首页模版，自动设置首页导航模版
      setting.update_attribute(:index_nav_template_id, home_template_relate_to_nav_template[setting.home_template_id])
    end
    
    # 取消内页对导航模版14的选择
    WebsiteSetting.update_all("nav_template_id = 0", "nav_template_id = 14")

    total = success = failed = 0

    if Rails.env.staging?
      websites = Website.micro_site.where(supplier_id: [10001, 10002])
    else
      websites = Website.micro_site
    end
    
    websites.each do |website|
      # next unless website.website_setting
      total += 1
      puts "网站：#{website.id}. #{website.name} =========================================================="
      begin
        website.website_popup_menus_initialize(WebsitePopupMenu::HOME_NAV_MENU)
        puts "初始化《首页》导航菜单成功！"
        success += 1
      rescue Exception => e
        puts "初始化《首页》导航菜单失败：#{e}"
        failed += 1
      end

      total += 1
      puts "---------------------------------------------------------------------------------"
      begin
        website.website_popup_menus_initialize(WebsitePopupMenu::INSIDE_NAV_MENU)
        puts "初始化《内页》导航菜单成功！"
        success += 1
      rescue Exception => e
        puts "初始化《内页》导航菜单失败：#{e}"
        failed += 1
      end
      puts ""
    end

    puts "total #{total}， success #{success}， failed #{failed}"

  end
end
