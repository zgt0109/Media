class ActivitiesBusinessShop < ActiveRecord::Base
  belongs_to :activity
  belongs_to :business_shop
end
