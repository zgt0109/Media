# -*- encoding : utf-8 -*-

namespace :dev do

  desc 'build test data ...'
  task test: [
    :create_website_menus,
  ]

  desc 'created suppliers'
  task :create_suppliers => :environment do
    puts 'Starting create suppliers ******'
    supplier = Supplier.where(nickname: 'wemedia').first_or_create(name: '微枚迪', password: 111111, password_confirmation: 111111, is_gift: true)
    puts "created supplier: #{supplier.name}"
  end

  task :update_product_category_ids => :environment do
    count = 0
    ShopProduct.find_each do |product|
      before_category_name = product.shop_category.name

      first_category = ShopCategory.where(supplier_id: product.supplier_id, name: before_category_name).first

      unless first_category.id == product.shop_category_id
        count += 1
        puts "#{first_category.id} <> #{product.shop_category_id}"
        product.update_attributes!(shop_category_id: first_category.id)
        product.shop_category.update_attributes!(status: -1, description: 'will remove this record')
        puts "update product: #{product.id} #{product.previous_changes}"
      end
    end
    puts "have #{count}"
  end

  desc 'created website_menus'
  task :create_website_menus => :environment do
    puts 'Starting create website_menus ******'
    next if WebsiteMenu.root.count > 5

    %w(关于我们 店庆活动 公司动态 企业动态 企业文化 联系我们).each do |name|
      website_menu = WebsiteMenu.create!(name: name, website_id: 1, material_id: 1)
      puts "created website_menu: #{website_menu.id} - #{website_menu.name}"
    end
    puts 'Done!'
  end

  desc 'created wx_replies'
  task :create_wx_replies => :environment do
    puts 'Starting create wx_replies ******'

    WxMpUser.where('welcome_msg is not null or default_reply is not null').each do |wx_mp_user|
      if wx_mp_user.welcome_msg.present?
        attrs = { event_type: WxReply::CLICK_EVENT, reply_type: WxReply::TEXT, content: wx_mp_user.welcome_msg }
        if wx_mp_user.first_follow_reply
          wx_mp_user.first_follow_reply.update_attributes(attrs)
          wx_reply=wx_mp_user.first_follow_reply
        else
          wx_reply=wx_mp_user.wx_replies.where(attrs).first_or_create(attrs)
        end
        puts "created wx_replies: #{wx_reply.id} - #{wx_reply.content}"
      end

      if wx_mp_user.default_reply.present?
        attrs = { event_type: WxReply::TEXT_EVENT, reply_type: WxReply::TEXT, content: wx_mp_user.default_reply }
        if wx_mp_user.text_reply
          wx_mp_user.text_reply.update_attributes(attrs)
          wx_reply=wx_mp_user.text_reply
        else
          wx_reply=wx_mp_user.wx_replies.where(attrs).first_or_create(attrs)
        end
        puts "created wx_replies: #{wx_reply.id} - #{wx_reply.content}"
      end

    end
    puts 'Done!'
  end

  desc 'update vip_user_no'
  task :update_vip_user_no => :environment do
    puts 'Starting update vip_user_no *******'

    VipUser.where(supplier_id: 10507).order(:id).each do |vip_user|
      next unless vip_user.user_no.start_with?('1688')

      vip_card_api_options = VipCardApi::CONFIG_OPTOINS

      client = VipCardApi.new(vip_card_api_options[vip_user.supplier_id])
      puts "client: #{client}"

      response = client.new_vip_card(vip_user.wx_user.openid, vip_user.name, vip_user.gender_name, vip_user.mobile)

      data = response[:data].split(',')

      if response[:result] == 1
        vip_user.user_no = data[1]
        vip_user.is_sync = true
        vip_user.save!
      else
        "申请失败：#{response[:data]}"
      end

      puts "update vip_user: #{vip_user.id} #{vip_user.previous_changes}"
    end
    puts "done"
  end

  desc 'update city'
  task :update_city => :environment do
    puts 'Starting update city ******'

    require 'ruby-pinyin'

    Province.find_each do |province|
      province.update_attributes(pinyin: PinYin.of_string(province.name).join)
      puts "update province #{province.name} #{province.pinyin}"
    end

    City.find_each do |city|
      city.update_attributes(pinyin: PinYin.of_string(city.name.gsub(/市|地区|自治州|特别行政区/,'')).join)
      puts "update city #{city.name} #{city.pinyin}"
    end

    puts 'Done!'
  end

  desc 'copy template css'
  task :css => :environment do
    rails_assets_gm_path = Rails.root.join('app','assets','stylesheets','main.css')
    svn_target_path = "/tmp/winwemedia_template"
    command = "svn co --username teddy --password ertdfg --depth=infinity svn://winwemedia.com/opt/apps/winwemedia/html/后台/模板 #{svn_target_path}"
    system command
    main_css_path = svn_target_path + '/css' + '/main.css'
    contents = File.read(main_css_path)
    contents = contents.gsub("../img","/assets/gm")
    local_main_css = File.new(rails_assets_gm_path, 'w')
    local_main_css.puts contents
    local_main_css.close
    require 'fileutils'
    FileUtils.cp_r(Dir.glob(svn_target_path + '/img/*'), Rails.root.join('app','assets','images','gm'))
  end

end
