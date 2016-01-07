class VipCardBranch < ActiveRecord::Base
  mount_uploader :pic, MaterialUploader
  img_is_exist({pic: :pic_key})
  belongs_to :vip_card
  belongs_to :cardable, polymorphic: true

  validates :name, presence: true, length: { maximum: 20 }
end
