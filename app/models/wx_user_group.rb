class WxUserGroup < ActiveRecord::Base
  has_many :wx_users ,foreign_key: "groupid", primary_key: "groupid"
  belongs_to :wx_mp_user
end
