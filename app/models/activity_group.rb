# == Schema Information
#
# Table name: activity_groups
#
#  id          :integer          not null, primary key
#  activity_id :integer          not null
#  wx_user_id  :integer          not null
#  name        :string(255)      not null
#  mobile      :string(255)      not null
#  item_qty    :integer          default(1), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ActivityGroup < ActiveRecord::Base
  # attr_accessible :title, :body
  #validates :name, presence: true
  #validates_format_of :mobile, presence: true, with: /^(13[0-9]|14[0-9]|15[0-9]|18[0|3|6|8|9])\d{8}$/
 
  belongs_to :activity
  belongs_to :wx_user
  
  has_many :activity_consumes
end
