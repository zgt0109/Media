class StatsWxUser < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :wx_mp_user
end
