class GreetCardItem < ActiveRecord::Base
  belongs_to :greet_card
  belongs_to :user
  belongs_to :greet_voice
  # attr_accessible :title, :body
end
