# -*- coding: utf-8 -*-
class PrintOrder < ActiveRecord::Base
  belongs_to :shop_order
  belongs_to :site
  belongs_to :shop_branch
  belongs_to :shop_branch_print_template
  attr_accessible :status, :address, :shop_order_id, :supplier_id, :shop_branch_id, :shop_branch_print_template_id
  scope :basic_columns, -> { select([:id, :shop_order_id, :status, :created_at]) }
  
  enum_attr :status, :in => [
  	['success', 1,'打印成功'],
  	['unprint', -1, '未打印'],
    ['touched', -2, '已连接']
  ]

  # 要被打印的单子 (传入参数)
  def self.to_be_print(print_no)
    where(address: print_no).where(status: -1).first
  end

  def self.is_duplicate?(address, shop_branch_id, shop_branch_print_template_id, shop_order_id)
    where(address: address).
    where(shop_branch_id: shop_branch_id).
    where(shop_order_id: shop_order_id).
    where(shop_branch_print_template_id: shop_branch_print_template_id).
    where(status: -1).
    count > 0
  end

  # 导出 excel
  def self.export_excel(supplier_id)
    book = PointTransaction.new_excel(title: '报表')
    book_excel = book[0]
    book_sheet = book[1]
    export_title = ['金额', "日期", "订单id", "客户id"]
    sing_sheet = []
    sing_sheet << export_title

    PrintOrder.where(supplier_id: supplier_id).includes(:shop_order).find_each do |order|
      shop_order = order.shop_order
      if shop_order
        money = shop_order.total_amount
        date = shop_order.created_at.to_s
        shop_order_id = shop_order.id
        custom_id = shop_order.wx_user_id
        sing_sheet << [money,date,shop_order_id,custom_id].flatten
      end
    end
    sing_sheet.each_with_index do |new_sheet,index|
      book_sheet.insert_row(index,new_sheet)
    end

    StringIO.new.tap { |s| book_excel.write(s) }.string
  end
end
