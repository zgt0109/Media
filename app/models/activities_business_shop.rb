class ActivitiesBusinessShop < ActiveRecord::Base
  belongs_to :activity
  belongs_to :business_shop
  # attr_accessible :title, :body
end
