class Interlocution < ActiveRecord::Base
	validates :interlocution_two_level_id, :question, :answer, :sort, presence: true
  belongs_to :interlocution_two_level
  # attr_accessible :answer, :description, :question, :sort, :status
end
