class ShopProductComment < ActiveRecord::Base
  belongs_to :shop_product
  belongs_to :user

  validates :content, presence: true
end
