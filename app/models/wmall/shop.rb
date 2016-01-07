class Wmall::Shop < ActiveRecord::Base
  # status: {:on, :off}
  acts_as_taggable_on :statuses, :categories
  has_many :products
  has_many :activities, class_name: "Wmall::ShopActivity"
  has_many :pictures, class_name: "Wmall::ShopPicture"
  has_many :comments, as: :commentable
  has_many :group_items, as: :groupable
  has_one :qrcode, as: :qrcodeable, class_name: "Wmall::Qrcode"
  belongs_to :mall
  acts_as_followable

  after_initialize :generate_sn

  def pic_url
    if pre_pic_url.present?
      pre_pic_url
    elsif pic_key.present?
      qiniu_image_url(pic_key, bucket: BUCKET_WMALL)
    else
      ""
    end
  end

  def all_count
    count = []
    count << self.activities.map{|a| a.followers_count}
    count << self.products.map{|p| p.followers_count}
    count.flatten.sum
  end

  #复写　acts_as_taggable_on的categories方法
  #def categories
  #  Tag.includes(:shop).where(taggable_id: id,taggable_type: "Shop")
  #end

  private
  def generate_sn
    self.sn = generate_sn_by_timestamp unless sn.present?
  end
end
