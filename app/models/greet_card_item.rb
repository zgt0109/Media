class GreetCardItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :greet_card
  belongs_to :greet_voice
end
