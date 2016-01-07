# == Schema Information
#
# Table name: car_bespeak_option_relationships
#
#  id                    :integer          not null, primary key
#  car_bespeak_id        :integer          not null
#  car_bespeak_option_id :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class CarBespeakOptionRelationship < ActiveRecord::Base
  attr_accessible :car_bespeak_id, :car_bespeak_option_id
  
  belongs_to :car_bespeak
  belongs_to :car_bespeak_option
end
