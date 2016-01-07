# == Schema Information
#
# Table name: provinces
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  pinyin     :string(255)
#  sort       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Province < ActiveRecord::Base
  validates :name, presence: true

  has_many :cities
  has_many :supplier_accounts
end
