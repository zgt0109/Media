class BusinessShopPicture < ActiveRecord::Base
  belongs_to :business_shop

  scope :recent, -> { order('id DESC') }

  def as_json
    { url: pic.to_s, caption: '' }.to_json
  end
end
