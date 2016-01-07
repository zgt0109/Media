# == Schema Information
#
# Table name: hotel_branches
#
#  id                :integer          not null, primary key
#  supplier_id       :integer          not null
#  wx_mp_user_id     :integer          not null
#  hotel_id          :integer          not null
#  name              :string(255)      not null
#  tel               :string(255)      not null
#  tel_extension     :string(255)
#  is_default        :boolean          default(FALSE), not null
#  province_id       :integer          default(9), not null
#  city_id           :integer          default(73), not null
#  district_id       :integer          default(702), not null
#  address           :string(255)      not null
#  business_district :string(255)      not null
#  status            :integer          default(1), not null
#  description       :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class HotelBranch < ActiveRecord::Base
  #attr_accessible :address, :business_district, :city_id, :description, :district_id, :hotel_id, :name, :province_id, :status, :supplier_id, :tel, :tel_extension, :wx_mp_user_id
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
