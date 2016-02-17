class WxUserTag < ActiveRecord::Base
  # attr_accessible :title, :body

  has_many :wx_users ,foreign_key: "groupid",primary_key: "groupid"
  belongs_to :wx_mp_user
end
