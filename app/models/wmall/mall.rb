class Wmall::Mall < ActiveRecord::Base
  belongs_to :supplier

  has_many :shops
  has_many :categories
  has_many :shop_accounts, through: :shops
  has_many :activities
  has_many :products
  has_many :slide_pictures
end


