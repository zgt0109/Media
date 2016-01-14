class HotelBranch < ActiveRecord::Base
  validates :name, :address, :tel, :business_district, presence: true

  belongs_to :hotel
  belongs_to :city
  belongs_to :district

  has_many :hotel_comments, dependent: :destroy
  has_many :hotel_pictures, dependent: :destroy
  has_many :hotel_orders, dependent: :destroy
  has_many :hotel_room_types, dependent: :destroy
  has_many :hotel_room_settings, dependent: :destroy

  def self.default_branch
    where(is_default: true).first || first
  end

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除']
  ]

  enum_attr :is_default, :in => [
    ['default', true, '是'],
    ['is_default', false, '否']
  ]

  def delete!
    update_attributes(status: DELETED) if normal?
  end

end
