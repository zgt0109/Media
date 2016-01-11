class VipCardBranch < ActiveRecord::Base

  belongs_to :vip_card
  belongs_to :cardable, polymorphic: true

  validates :name, presence: true, length: { maximum: 20 }
end
