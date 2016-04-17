class BusinessShop < ActiveRecord::Base

  belongs_to :website
  has_one    :activity,        as: :activityable
  has_one    :vip_card_branch, as: :cardable
  has_many   :business_privileges, dependent: :destroy
  has_many   :business_items,      dependent: :destroy
  has_many   :business_shop_pictures,     dependent: :destroy
  has_many   :comments, as: :commentable, dependent: :destroy
  has_one    :business_shop_admin, dependent: :destroy
  has_many   :activities_business_shops, dependent: :destroy
  has_many   :activities, through: :activities_business_shops
  has_many   :business_shop_impressions, dependent: :destroy

  scope :sorted, -> { order('sort ASC') }

  after_save   :make_activity_deleted
  after_create :save_vip_card_branch_to_db

  validates :name, :tel, :address, :description, presence: true
  # validates :logo_key, presence: true, on: :create
  validates :sort, numericality: { only_integer: true, greater_than: 0 }

  accepts_nested_attributes_for :activity

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :location_status, :in => [
    ['location_none', 1, '不显示位置导航'],
    ['location_normal', 2, '显示位置导航'],
    ['location_picture', 3, '使用图片'],
  ]

  def save_vip_card_branch_to_db
    site = website.site
    site.create_activity_for_vip_card unless site.vip_card
    unless vip_card_branch
      create_vip_card_branch(name: '店铺', discount_name: '微生活店铺', vip_card: site.vip_card(true), pic_key: site.vip_card.cover_pic_key)
    end
  end

  def delete!
    update_attributes!(status: DELETED)
    activity.deleted!
  end

  def logo_url
    qiniu_image_url(logo_key)
  end

  private
    def make_activity_deleted
      activity.try :delete! if deleted?
    end
end
