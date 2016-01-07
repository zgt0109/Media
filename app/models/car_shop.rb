# == Schema Information
#
# Table name: car_shops
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  name          :string(255)      not null
#  tel           :string(255)      not null
#  tel_extension :string(255)
#  province_id   :integer          default(9), not null
#  city_id       :integer          default(73), not null
#  district_id   :integer          default(702), not null
#  address       :string(255)      not null
#  intro         :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CarShop < ActiveRecord::Base
  # validates :name, :intro, :address, :tel, presence: true
  validates :name, presence: true

  has_many :car_bespeaks, dependent: :destroy
  has_many :car_sellers, dependent: :destroy
  has_many :car_articles, dependent: :destroy
  has_many :car_brands, dependent: :destroy
  has_one :car_brand, dependent: :destroy
  has_many :car_catenas, dependent: :destroy
  has_many :car_types, dependent: :destroy
  has_many :car_activity_notices, dependent: :destroy
  has_many :car_pictures, dependent: :destroy
  has_many :car_owners, dependent: :destroy
  belongs_to :city

  accepts_nested_attributes_for :car_brands
  accepts_nested_attributes_for :car_brand
  accepts_nested_attributes_for :car_activity_notices

  def self.get_type_html(types)
    html = ""
    types.each do |type|
      pic = type.car_pictures.present? ? type.car_pictures.first.path.big : "/assets/mobile/wcar/p8.jpg"
      price = format("%.2f", type.dealer_price)
      html << "<li><a>"
      html << "<p class='car-img fl'><img src='#{pic}'/></p>"
      html << "<p class='car-info fr'>"
      html << "<span><b>车型：</b>#{type.name}</span>"
      html << "<span><b>排量：</b>#{type.output_volumne}</span>"
      html << "<span><b>价格：</b>￥#{price}</span>"
      html << "</p></a></li>"
    end
    return html
  end

  def activity
    car_activity_notices.last.activity
  end

end
