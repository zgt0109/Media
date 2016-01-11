# == Schema Information
#
# Table name: ec_shops
#
#  id                :integer          not null, primary key
#  supplier_id       :integer          not null
#  wx_mp_user_id     :integer          not null
#  name              :string(255)      not null
#  logo              :string(255)
#  cover_pic         :string(255)
#  is_open_cover_pic :boolean          default(TRUE)
#  status            :integer          default(0), not null
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class EcShop < ActiveRecord::Base

  belongs_to :site
  belongs_to :wx_mp_user
  has_many :categories, :class_name => "EcSellerCat", :dependent => :destroy#, order: :sort_order
  has_many :ads, :class_name => "EcAd"
  has_one :activity, as: :activityable
  has_many :ec_items
  has_many :ec_orders

  validates :name, presence: true, length: { maximum: 64, message: '电商名称过长' }

  accepts_nested_attributes_for :activity

  def clear_menus!
    categories.clear
  end

  def show_categories
    return [['','']] unless self.categories.present?
    attrs = []
    self.categories.order(:sort_order).root.select{|cate|
                                             attrs << [cate.name, cate.id]
                                             cate.children.select{|sub_cate| attrs << ["#{cate.name} > #{sub_cate.name}", sub_cate.id]}
                                             }.flatten
    attrs

  end

  def multilevel_menu params
    ec_seller_cats, ec_seller_cat_selects = categories.root.normal.order(:sort_order), []
    index = 1
    ec_seller_cat_selects.push([index, ec_seller_cats])
    return ec_seller_cat_selects if params["ec_seller_cat_id#{index}".to_sym].to_i <= 0 && params[:action] == 'index'
    if params["ec_seller_cat_id#{index}".to_sym].present?
      ec_seller_cats.where(id: params["ec_seller_cat_id#{index}".to_sym].to_i).first.try(:multilevel_menu_down, index + 1, params, ec_seller_cat_selects)
    else
      ec_seller_cats.first.try(:multilevel_menu_down, index + 1, params, ec_seller_cat_selects)
    end
    ec_seller_cat_selects
  end

  def show_items params

    return [] unless self.categories.present?

    items = []
    categories.root.each do |category|
      if category.has_children?
        if category.id == params[:ec_seller_cat_id].to_i
          items << category.ec_items
          category.items params, items, true
        else
          category.items params, items
        end
      else
        next unless category.id == params[:ec_seller_cat_id].to_i
        items << category.ec_items
      end
    end if params[:ec_seller_cat_id].present?

    items = ec_items unless params[:ec_seller_cat_id].present?

    items = items.flatten

    items = items.select{|item| item.id == params[:id].to_i} if params[:id].present?

    items = items.select{|item| item.title =~ /.*(#{params[:title].strip()}).*/} if params[:title].present?

    items = items.select{|item| item.status == params[:status].to_i} if params[:status].present?

    items.flatten.sort{|x, y| y.created_at <=> x.created_at }
  end




end
