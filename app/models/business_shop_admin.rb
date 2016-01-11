class BusinessShopAdmin < ActiveRecord::Base
	has_secure_password

  belongs_to :business_shop

  validates :name, presence: true, on: :update

  validates :password, presence: true, length: { within: 4..20 }

  def name
    username.to_s.sub(/@\d+$/, '')
  end

  def name=(name)
    name_suffix = business_shop.try(:website).try(:id)
    self.username = "#{name}@#{name_suffix}"
  end

end
