# == Schema Information
#
# Table name: ec_items
#
#  id            :integer          not null, primary key
#  site_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  ec_shop_id    :integer
#  cid           :integer
#  seller_cid    :integer
#  iid           :string(255)
#  num_iid       :integer
#  title         :string(255)      not null
#  price         :decimal(12, 2)   default(0.0), not null
#  pic_url       :string(500)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class EcItem < ActiveRecord::Base

  belongs_to :site
  belongs_to :wx_mp_user

  belongs_to :ec_seller_cat, :primary_key => :cid, foreign_key: :seller_cid
  has_many :ec_comments
  has_many :ec_order_items
  has_many :ec_item_pictures
  has_one :ec_cart, :dependent => :destroy
  belongs_to :ec_shop

  validates :title, presence: true
  validates :price, presence: true
  validates :price, numericality: {greater_than: 0}
  #validates :num_iid, :presence => true
  #validates :pic_url, presence: true, on: :create
  # validates :pic_url, presence: true, format: { with: /^(http|https):\/\/[a-zA-Z0-9].+$/, message: '地址格式不正确，必须以http(s)://开头' }

  before_create :add_default_attrs

  accepts_nested_attributes_for :ec_item_pictures, allow_destroy: true
  validates_associated :ec_item_pictures

  enum_attr :status, :in => [
      ['deleted',  -1,  '已下架'],
      ['selling',     1,  '销售中']
  ]

  def delete!
    status = self.deleted? ? SELLING : DELETED
    update_column('status', status)
  end

  def main_picture
    ec_item_pictures.first
  end

  def total_sale_products
    order_items = self.ec_order_items
    sum = 0
    order_items.select{|it| sum += it.qty}
    return sum
  end

  def self.get_conditions params
    conn = [[]]
    if params[:id].present?
      conn[0] << "ec_items.id = ?"
      conn << "#{params[:id].strip}"
    end

    if params[:name].present?
      conn[0] << "ec_items.name like ?"
      conn << "%#{params[:name].strip}%"
    end

    conn[0] = conn[0].join(' and ')
    conn
  end


  def multilevel_menu params
    return [[1, []]] unless ec_shop
    unless ec_seller_cat
      categories , ec_seller_cat_selects = ec_shop.categories.root.order(:sort_order), []
      ec_seller_cat_selects.unshift([1, categories])
      categories.first.try(:multilevel_menu_down, 2, params, ec_seller_cat_selects)
      return ec_seller_cat_selects
    end

    num, ec_seller_cat_selects = ec_seller_cat.allow_menu_layer(1, true), []
    params["ec_seller_cat_id#{num}".to_sym] = ec_seller_cat.id

    if ec_seller_cat.parent_id == 0
      ec_seller_cat_selects.unshift([num, ec_shop.categories.normal.root.order(:sort_order)])
    else
      children1 = ec_seller_cat.parent.children.normal
      ec_seller_cat_selects.unshift([num, children1])
      ec_seller_cat.parent.try(:multilevel_menu_up, num - 1, params, ec_seller_cat_selects)

      if ec_seller_cat.normal?
        children2 = ec_seller_cat.children.normal
        if children2.count > 0
          params["ec_seller_cat_id#{num + 1}".to_sym] = children2.first.try(:id)
          ec_seller_cat_selects.push([num + 1, ec_seller_cat.children.normal])
        end
      else
        if children1.first.present?
          children3 = children1.first.children.normal
          params["ec_seller_cat_id#{num + 1}".to_sym] = children3.first.try(:id)
          ec_seller_cat_selects.push([num + 1, children3])
        end

      end

    end

    ec_seller_cat_selects
  end

  private

  def add_default_attrs
    return unless site
    self.wx_mp_user_id = site.wx_mp_user.try(:id)
    self.ec_shop_id = site.ec_shop.try(:id)
  end
end
