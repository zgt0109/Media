# -*- coding: utf-8 -*-
# == Schema Information
#
# Table name: shop_products
#
#  id               :integer          not null, primary key
#  supplier_id      :integer          not null
#  wx_mp_user_id    :integer          not null
#  shop_id          :integer          not null
#  shop_branch_id   :integer          not null
#  shop_category_id :integer          not null
#  name             :string(255)      not null
#  code             :string(255)      not null
#  price            :decimal(12, 2)   default(0.0), not null
#  discount         :decimal(6, 2)    default(0.0), not null
#  is_new           :boolean          default(FALSE), not null
#  is_hot           :boolean          default(FALSE), not null
#  pic_url          :string(255)
#  status           :integer          default(1), not null
#  description      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ShopProduct < ActiveRecord::Base
  # attr_accessible :code, :description,  :is_hot, :is_new, :name, :pic_url, :price, :status
  mount_uploader :pic_url, ShopImageUploader

  # validates :shop_branch_id, :shop_category_id, presence: true
  validates :shop_menu_id, presence:true
  validates :name, presence: true, length: { maximum: 15 }

  validates :sort, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :qiniu_pic_key, presence: true, on: :create

  # validates :quantity, numericality: { greater_than_or_equal_to: 0, only_integer: true }, allow_blank: true
  
  enum_attr :is_hot, :in => [ ['hot', true, '是'], ['not_hot', false, '否'] ]
  enum_attr :is_new, :in => [ ['new_proudcts', true, '是'], ['not_new', false, '否'] ]
  enum_attr :shelve_status, :in => [ 
    ['not_shelve', 0, '已下架'], 
    ['shelve',     1, '已上架'] 
  ]

  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :shop
  # belongs_to :shop_branch
  belongs_to :shop_category
  belongs_to :shop_menu
  has_many :shop_product_comments

  # scope :my_limit, ->(num) { limit(num)}
  # scope :root, ->(c_id) { where(parent_id: ?), c_id }
  before_create :add_default_attrs


  default_scope where(["shop_products.status != ? ", -1 ])

  def self.import_from_excel(file, supplier)
    # Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet.open(file)
    sheet = book.worksheet(0)

    transaction do
      sheet.each_with_index do |row, i|
        next if i == 0

        shop_branch = supplier.shop_branches.where(name: row[0]).first
        shop_category = supplier.shop_categories.where(name: row[1]).first
        next unless shop_branch
        next unless shop_category

        puts row

        attrs = {
          shop_branch_id: shop_branch.id,
          shop_category_id: shop_category.id,
          name: row[2],
          price: row[3],

          is_new: row[5],
          is_hot: row[6],
          pic_url: row[7],
          description: row[8]
        }

        product = ShopProduct.where(name: row[2]).first

        product ? product.update_attributes(attrs) : ShopProduct.create(attrs)
      end
    end
  end

  # def pic_path
  #   "/uploads/shop_image/pic/#{shop_branch_id}/thumb_#{pic_url}"
  # end

  def bother_count
    if self.shop_category_id
      return self.shop_category.shop_products.count
    else
      return ShopProduct.where(category_parent_id: self.category_parent_id).count
    end
  end

  def pic_url_url
    qiniu_image_url(qiniu_pic_key) || pic_url
  end

  def thumb_qiniu_pic_url
    # 七牛缩略图说明 http://developer.qiniu.com/docs/v6/api/reference/fop/image/imageview2.html
    pic_url_url && "#{pic_url_url}?imageView2/1/w/60/h/60"
  end


  def update_sort sort_value
    same_sort_products = self.shop_menu.shop_products.where(sort: sort_value)
    same_sort_products.each do |p|
      unless p.id == self.id
        p.update_sort(p.sort + 1)
      end
    end
    self.update_column("sort", sort_value)
  end

  def soft_delete
    self.update_column("status", -1)
  end

  private

  def add_default_attrs
    return unless self.shop
    self.supplier_id = self.shop.supplier_id
    self.wx_mp_user_id = self.shop.wx_mp_user_id
    self.code = "#{self.category_parent_id}_#{self.shop.shop_products.count+1}"
    self.pic_url = self.qiniu_pic_key if self.qiniu_pic_key
  end
  

end
