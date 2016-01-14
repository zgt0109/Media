class CollegeMajor < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :college
  has_many :college_enrolls
  validates :name, :description, presence: true

end
