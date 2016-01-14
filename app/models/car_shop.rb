class CarShop < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :city
  has_one :car_brand, dependent: :destroy
  has_many :car_bespeaks, dependent: :destroy
  has_many :car_sellers, dependent: :destroy
  has_many :car_articles, dependent: :destroy
  has_many :car_brands, dependent: :destroy
  has_many :car_catenas, dependent: :destroy
  has_many :car_types, dependent: :destroy
  has_many :car_activity_notices, dependent: :destroy
  has_many :car_pictures, dependent: :destroy
  has_many :car_owners, dependent: :destroy

  accepts_nested_attributes_for :car_brands
  accepts_nested_attributes_for :car_brand
  accepts_nested_attributes_for :car_activity_notices

  def self.get_type_html(types)
    html = ""
    types.each do |type|
      pic = type.car_pictures.present? ? type.car_pictures.first.pic_path_url : "/assets/mobile/wcar/p8.jpg"
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
