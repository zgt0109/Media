class InterlocutionTwoLevel < ActiveRecord::Base
	validates :interlocution_one_level_id, :name, :sort, presence: true
  belongs_to :interlocution_one_level
  has_many :interlocutions
  # attr_accessible :description, :name, :sort, :status
end
