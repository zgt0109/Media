class CarBespeakOptionRelationship < ActiveRecord::Base
  attr_accessible :car_bespeak_id, :car_bespeak_option_id

  belongs_to :car_bespeak
  belongs_to :car_bespeak_option
end
