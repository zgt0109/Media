# -*- encoding : utf-8 -*-
namespace :import_ec_items do

  desc 'import ec_items'

  task test: [
      :import_ec_items,
  ]

  task :import_ec_items => :environment do

    puts 'Starting import ec_items ******'



    require 'rubygems'
    require 'roo'

    supplier = Supplier.where(nickname: '关爱宝').first
    return unless supplier

    ec_shop = supplier.ec_shop
    return unless ec_shop

    oo =  Roo::Excelx.new(File.join(Rails.root, 'public', 'import', 'ec_items.xlsx'))
    oo.default_sheet = oo.sheets.first
    2.upto(200) do |line|

      #一级分类
      category_name1  = oo.cell(line,'A')

      #二级分类
      category_name2 =  oo.cell(line,'B')

      #商品名称
      title =  oo.cell(line,'C')

      #商品价格
      price =  oo.cell(line,'E').to_f

      #商品描述
      description =  oo.cell(line,'F').to_s.split("\n").map{|f| "<p>#{f}</p>"}.join()

      #创建一级分类
      full_attrs = {
          ec_shop_id: ec_shop.id,
          name: category_name1,
          sort_order: supplier.ec_seller_cats.root.order(:sort_order).try(:last).try(:sort_order).to_i + 1
      }
      categroy1 = supplier.ec_seller_cats.root.where(name: category_name1).first_or_create(full_attrs)

      puts "categroy1: #{categroy1.id} - #{categroy1.name}"

      #创建二级分类
      full_attrs = {
          ec_shop_id: ec_shop.id,
          parent_id: categroy1.id,
          parent_cid: categroy1.id,
          name: category_name2,
          sort_order: categroy1.children.order(:sort_order).try(:last).try(:sort_order).to_i + 1
      }
      categroy2 = categroy1.children.where(name: category_name2).first_or_create(full_attrs)
      puts "categroy2: #{categroy2.id} - #{categroy2.name}"

      #创建商品
      full_attrs = {
          supplier_id: supplier.id,
          seller_cid: categroy2.id,
          title: title,
          price: price,
          description: description
      }
      ec_item = categroy2.ec_items.new(full_attrs)
      ec_item.save

      puts "ec_item: #{ec_item.id} - #{ec_item.title}"

    end

    puts 'End import ec_items ******'
  end
end