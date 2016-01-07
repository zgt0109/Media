# == Schema Information
#
# Table name: house_layouts
#
#  id               :integer          not null, primary key
#  house_id         :integer          not null
#  layout_number    :string(255)      not null
#  name             :string(255)      not null
#  reference_area   :decimal(12, 2)   not null
#  floor_height     :decimal(12, 2)   not null
#  orientation      :string(255)      not null
#  price            :decimal(12, 2)   not null
#  sales_heat       :integer          default(0), not null
#  house_picture_id :integer
#  intro            :text             default(""), not null
#  status           :integer          default(1), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class HouseLayout < ActiveRecord::Base

  #validates :layout_number presence: true
  validates :name, :orientation, presence: true
  validates :reference_area, :floor_height, :price, :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000000.00}
  validates :intro, presence: true, length: { maximum: 1000 }

  belongs_to :house
  belongs_to :house_picture
  has_many :house_pictures, dependent: :nullify
  has_many :panoramas, class_name: "HouseLayoutPanorama", dependent: :destroy
  has_many :standalone_panoramas, as: :panoramic, class_name: "StandalonePanorama", dependent: :destroy

  accepts_nested_attributes_for :house_pictures

  before_save :save_hidden_fields

  acts_as_taggable_on :panorama_type

  enum_attr :sales_heat, :in => [
    ['hot', 0, '热销'],
    ['quota', 1, '限量'],
    ['few', 2, '少量'],
    ['group', 3, '团购'],
    ['preferential', 4, '优惠'],
    ['discount', 5, '折扣'],
    ['picked', 6, '精品'],
    ['highest', 7, '极品'],
  ]

  enum_attr :status, :in => [
    ['normal', 1, '正常'],
    ['deleted', -1, '已删除'],
  ]

  def save_hidden_fields
    self.reference_area = 1 unless reference_area
    self.floor_height   = 1.0 unless floor_height
    self.price          = 1 unless price
    self.sales_heat     = 1 unless sales_heat
  end

end
