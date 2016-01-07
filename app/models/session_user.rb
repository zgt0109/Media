class SessionUser < ActiveRecord::Base
  BEGIN_ID = 1000_000_000

  belongs_to :supplier
  belongs_to :wx_mp_user
  has_many :activity_users, foreign_key: :wx_user_id, conditions: "wx_user_id > #{BEGIN_ID}"

  attr_accessor :nickname, :mobile, :vip_user

  [:subscribe?, :has_info?, :wx_user?].each do |method_name|
    define_method(method_name) { false }
  end

end
