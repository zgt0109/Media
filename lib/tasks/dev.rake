# -*- encoding : utf-8 -*-

namespace :dev do

  desc 'build test data ...'
  task test: [
    :create_accounts,
  ]

  desc 'created accounts'
  task :create_accounts => :environment do
    puts 'Starting create accounts ******'
    account = Account.where(nickname: 'wemedia').first_or_create(company_name: '微枚迪', password: 111111, password_confirmation: 111111, mobile: 13899998888, email: 'test@winwemedia.com')
    puts "created account: #{account.nickname}"
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
