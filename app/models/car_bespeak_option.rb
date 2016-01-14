class CarBespeakOption < ActiveRecord::Base
  attr_accessible :bespeak_type, :name, :sort

  has_many :car_bespeak_option_relationships

  enum_attr :bespeak_type, :in => [
    ['repair', 1, '保养预约'],
    ['test_drive', 2, '试驾预约'],
  ]

end
