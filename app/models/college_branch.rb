# == Schema Information
#
# Table name: college_branches
#
#  id            :integer          not null, primary key
#  supplier_id   :integer          not null
#  wx_mp_user_id :integer          not null
#  college_id    :integer          not null
#  name          :string(255)      not null
#  tel           :string(255)      not null
#  province_id   :integer          default(9), not null
#  city_id       :integer          default(73), not null
#  district_id   :integer          default(702), not null
#  address       :string(255)      not null
#  status        :integer          default(1), not null
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class CollegeBranch < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :college
  belongs_to :supplier
  belongs_to :wx_mp_user
  belongs_to :province
  belongs_to :city
  belongs_to :district

  validates :name, :tel, :address, presence: true
end
