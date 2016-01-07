# == Schema Information
#
# Table name: car_bespeak_options
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  sort         :integer          default(0), not null
#  bespeak_type :integer          default(1), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class CarBespeakOption < ActiveRecord::Base
  attr_accessible :bespeak_type, :name, :sort
  
  has_many :car_bespeak_option_relationships
  
  enum_attr :bespeak_type, :in => [
    ['repair', 1, '保养预约'],
    ['test_drive', 2, '试驾预约'],
  ]

end
