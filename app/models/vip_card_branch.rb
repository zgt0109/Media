class VipCardBranch < ActiveRecord::Base

  belongs_to :vip_card
  belongs_to :cardable, polymorphic: true

  validates :name, presence: true, length: { maximum: 20 }

  def pic_url
    pic_key.present? ? "http://#{BUCKET_PICTURES}.#{QINIU_DOMAIN}/#{pic_key}" : nil
  end
end
