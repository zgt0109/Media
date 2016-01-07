class InterlocutionOneLevel < ActiveRecord::Base

  validates :name, :sort, presence: true

  has_many :interlocution_two_levels
  has_many :interlocutions, through: :interlocution_two_levels
  
end
