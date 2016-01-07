class UserGreetCard < ActiveRecord::Base
  belongs_to :greet_card
  belongs_to :wx_user
  belongs_to :user_voice
  # attr_accessible :title, :body
end
