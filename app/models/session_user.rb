class SessionUser < ActiveRecord::Base
  BEGIN_ID = 1000_000_000

  belongs_to :site
  has_many :activity_users, foreign_key: :user_id, conditions: "user_id > #{BEGIN_ID}"

  attr_accessor :nickname, :mobile, :vip_user

  [:subscribe?, :has_info?, :user?].each do |method_name|
    define_method(method_name) { false }
  end

end
