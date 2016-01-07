# == Schema Information
#
# Table name: cities
#
#  id          :integer          not null, primary key
#  name        :string(255)      not null
#  pinyin      :string(255)
#  province_id :integer          default(9), not null
#  sort        :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class City < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :province
  has_many :districts
  has_many :hotel_branches
  has_many :supplier_accounts
end
