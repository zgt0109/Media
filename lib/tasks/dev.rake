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

end
