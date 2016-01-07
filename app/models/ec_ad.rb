# == Schema Information
#
# Table name: ec_ads
#
#  id         :integer          not null, primary key
#  ec_shop_id :integer
#  title      :string(255)
#  pic        :string(255)
#  sort       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EcAd < ActiveRecord::Base
  belongs_to :ec_shop
  belongs_to :menuable, polymorphic: true

  attr_accessor :seller_cid, :ec_item_id, :activity_id

  validates :pic, presence: true, on: :create

  before_save :cleanup

  qiniu_image_for :pic, key_prefix: 'pic/'

  enum_attr :menu_type, :in => [
      ['uncheck', 0, '不选'],
      ['category', 1, '商品类别'],
      ['product', 3, '具体商品'],
      ['link', 6, '链接'],
      ['activity', 2, '活动'],
  ]

  def multilevel_menu params
    return [1, []] unless ec_shop
    return [1, []] unless menuable

    num, ec_seller_cat_selects = menuable.allow_menu_layer(1, true), []
    params["ec_seller_cat_id#{num}".to_sym] = menuable.id

    if menuable.parent_id == 0
      ec_seller_cat_selects.unshift([num, ec_shop.categories.root.order(:sort_order)])
    else
      ec_seller_cat_selects.unshift([num, menuable.parent.try(:children)])
      menuable.parent.try(:multilevel_menu_up, num - 1, params, ec_seller_cat_selects)
    end

    ec_seller_cat_selects
  end


  private

  def cleanup
    if category?
      self.url = nil
      self.menuable_id = self.seller_cid
      self.menuable_type = 'EcSellerCat'
    elsif product?
      self.url = nil
      self.menuable_id = self.ec_item_id
      self.menuable_type = 'EcItem'
    elsif activity?
      self.url = nil
      self.menuable_id = self.activity_id
      self.menuable_type = 'Activity'
    elsif link?
      self.menuable_id = nil
      self.menuable_type = nil
    else
      self.url = nil
      self.menuable_id = nil
      self.menuable_type = nil
    end

  end


end
