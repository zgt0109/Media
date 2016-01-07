class ShopProductComment < ActiveRecord::Base
  belongs_to :shop_product
  belongs_to :wx_user

  validates :content, presence: true
end
