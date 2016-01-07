class HouseImpression < ActiveRecord::Base
  belongs_to :house

  validates_presence_of :house_id, :content
end
