# == Schema Information
#
# Table name: shop_images
#
#  id             :integer          not null, primary key
#  supplier_id    :integer          not null
#  wx_mp_user_id  :integer          not null
#  shop_id        :integer          not null
#  shop_branch_id :integer          not null
#  pic            :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ShopImage < ActiveRecord::Base
  mount_uploader :pic, ShopImageUploader

  validates :pic, presence: true, uniqueness: { case_sensitive: false, if: :has_pic? }

  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :shop
  belongs_to :shop_branch
  # attr_accessible :pic

  before_create :add_default_attrs

  def pic_name
    read_attribute(:pic)
  end

  def has_pic?
    shop_branch.shop_images.where(pic: pic_name)
  end

  private

  def add_default_attrs
    return unless self.shop_branch

    self.supplier_id = self.shop_branch.supplier_id
    self.wx_mp_user_id = self.shop_branch.wx_mp_user_id
    self.shop_id = self.shop_branch.shop_id
  end
end
