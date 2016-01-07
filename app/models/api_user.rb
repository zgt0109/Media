# == Schema Information
#
# Table name: api_users
#
#  id            :integer          not null, primary key
#  supplier_id   :integer
#  provider      :string(255)      not null
#  uid           :string(255)      not null
#  name          :string(255)
#  nickname      :string(255)
#  email         :string(255)
#  token         :string(255)
#  refresh_token :string(255)
#  expires_at    :datetime
#  avatar        :string(255)
#  description   :text
#  status        :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ApiUser < ActiveRecord::Base
  enum_attr :provider, :in => [
    ['bqq', '企业QQ'],
    ['yeahsite', '微枚迪易站'],
  ]

  enum_attr :account_type, :in => [
    ['bqqv2', 0, '2.0版本'],
    ['bqqv3', 1, '3.0版本'],
  ]
  
  belongs_to :supplier

  # before_save :generate_token

  def token_expired?
    return true if expires_at.blank?

    Time.now >= expires_at
  end

  def refresh_token
    update_attributes(token: SecureRandom.hex(16))
  end

end
