# == Schema Information
#
# Table name: districts
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  pinyin     :string(255)
#  city_id    :integer          default(73), not null
#  sort       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class District < ActiveRecord::Base
  validates :name, presence: true

  belongs_to :city
end
