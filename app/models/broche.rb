class Broche < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :broche
  has_one :activity, as: :activityable , dependent: :destroy
  has_many :broche_photos

  def sort_value
    self.broche_photos.try(:last).try(:sort).to_i + 1
  end
end
