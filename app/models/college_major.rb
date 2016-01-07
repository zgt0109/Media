# == Schema Information
#
# Table name: college_majors
#
#  id          :integer          not null, primary key
#  college_id  :integer          not null
#  name        :string(255)      not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CollegeMajor < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :college
  has_many :college_enrolls
  validates :name, :description, presence: true

end
