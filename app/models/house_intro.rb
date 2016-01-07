class HouseIntro < ActiveRecord::Base
  belongs_to :house
  has_many :pictures, class_name: 'HouseIntroPicture'

  validates_presence_of :house_id, :description

  def pic_url
    pic_key.present? ? qiniu_image_url(pic_key) : ''
  end

  def distance_between(other_intro)
    Geocoder::Calculations.distance_between([location_x, location_y], [other_intro[:location_x], other_intro[:location_y]],units: :km).round(3)
  end

end
