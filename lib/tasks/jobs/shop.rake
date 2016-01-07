
namespace :shop do

  desc 'created shop_table_settings'
  task :shop_table_settings => :environment do
    puts 'Starting create shop_table_settings ****** will create 31 rows per shop_branches!'
    Supplier.where('supplier_industry_id in (10001, 10002) or is_gift = 1').each do |supplier|
      puts "**************supplier #{supplier.id}"
      supplier.shop_branches.used.find_each do |shop_branch|
        (Date.today..Date.today+31.days).each do |date|
          puts "******date #{date} shop_branch_id #{shop_branch.id}"
          attrs = {
            open_hall_count: shop_branch.open_hall_count,
            open_loge_count: shop_branch.open_loge_count
          }
          shop_branch.shop_table_settings.where(shop_branch_id: shop_branch.id, date: date).first_or_create(attrs)
        end
      end
    end
    puts 'Done!'
  end

end
