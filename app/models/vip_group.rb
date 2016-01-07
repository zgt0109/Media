class VipGroup < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :vip_card
  has_many :vip_users, dependent: :nullify
  has_many :vip_cares
end
